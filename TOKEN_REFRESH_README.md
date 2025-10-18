# Token Refresh Flow Documentation

## Overview
The EduConnect API now supports token refresh functionality to handle token expiration gracefully. This prevents users from being logged out when their access tokens expire.

## How It Works

### 1. Login Response
When a user logs in successfully, the API returns both an access token and a refresh token:

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### 2. Token Storage
The Flutter app should store both tokens securely:
- **Access Token**: Used for API requests (expires in 60 minutes)
- **Refresh Token**: Used to get new access tokens (expires in 7 days)

### 3. Automatic Token Refresh
The Flutter app should implement automatic token refresh when API requests fail with 401 Unauthorized:

```dart
// Example implementation in ApiService
Future<http.Response> _makeAuthenticatedRequest(String url, Map<String, String> headers) async {
  headers['Authorization'] = 'Bearer $_accessToken';

  var response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 401) {
    // Try to refresh token
    bool refreshed = await _refreshAccessToken();
    if (refreshed) {
      // Retry request with new token
      headers['Authorization'] = 'Bearer $_accessToken';
      response = await http.get(Uri.parse(url), headers: headers);
    } else {
      // Refresh failed, user needs to login again
      await _logoutUser();
      throw Exception('Authentication expired');
    }
  }

  return response;
}

Future<bool> _refreshAccessToken() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];

      // Update stored tokens
      await AuthStorage.saveTokens(_accessToken, _refreshToken);
      return true;
    }
  } catch (e) {
    print('Token refresh failed: $e');
  }
  return false;
}
```

### 4. Token Storage Helper
Create a helper class for secure token storage:

```dart
class AuthStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
```

## Error Handling

### 401 Unauthorized Response
When an access token expires, the API returns:
```json
{
  "success": false,
  "error": {
    "message": "Authentication failed",
    "code": "AUTHENTICATION_ERROR",
    "type": "AuthenticationError"
  }
}
```

### Refresh Token Invalid
When a refresh token is invalid or expired:
```json
{
  "success": false,
  "error": {
    "message": "Invalid refresh token",
    "code": "AUTHENTICATION_ERROR",
    "type": "AuthenticationError"
  }
}
```

## Security Considerations

1. **Token Storage**: Store tokens securely using Flutter's secure storage or encrypted preferences
2. **Token Rotation**: Implement proper token rotation by updating both tokens on refresh
3. **Logout Handling**: Clear both tokens on logout
4. **Network Security**: Always use HTTPS for API requests
5. **Token Validation**: Validate token format and expiration before use

## Testing the Flow

1. Login to get initial tokens
2. Wait for access token to expire (or manually expire it)
3. Make an API request that should trigger automatic refresh
4. Verify that new tokens are received and stored
5. Test refresh token expiration scenario

## Migration Guide

For existing apps using the old authentication system:

1. Update login handling to store both tokens
2. Implement automatic token refresh logic
3. Update logout to clear both tokens
4. Test thoroughly before deploying
