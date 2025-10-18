import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

/// WebSocket Chat Service
/// Handles real-time chat communication with fallback to HTTP polling
class ChatWebSocketService {
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://gyanvruksh.onrender.com');

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pollingTimer;

  // Connection state
  bool _isConnected = false;
  String _currentRoom = 'general';
  String? _accessToken;

  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  bool get isConnected => _isConnected;

  /// Initialize the service and load auth token
  Future<void> initialize() async {
    _accessToken = await AuthStorage.getToken();
    if (_accessToken != null) {
      _connectionStatusController.add('initialized');
    }
  }

  /// Connect to WebSocket for a specific room
  Future<bool> connect(String roomId) async {
    if (_accessToken == null) {
      debugPrint('ChatWebSocket: No access token available');
      _connectionStatusController.add('error_no_token');
      return false;
    }

    try {
      _currentRoom = roomId;

      // Close existing connection if any
      await disconnect();

      final wsUrl = 'ws://${_baseUrl.replaceFirst('https://', '')}/api/chat/ws/$roomId?token=$_accessToken';

      debugPrint('ChatWebSocket: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onDone: () {
          debugPrint('ChatWebSocket: Connection closed');
          _isConnected = false;
          _connectionStatusController.add('disconnected');
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint('ChatWebSocket: Connection error: $error');
          _isConnected = false;
          _connectionStatusController.add('error');
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      _connectionStatusController.add('connected');

      // Start heartbeat to keep connection alive
      _startHeartbeat();

      return true;
    } catch (e) {
      debugPrint('ChatWebSocket: Connection failed: $e');
      _isConnected = false;
      _connectionStatusController.add('error');
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();
    _stopPolling();

    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _isConnected = false;
    _connectionStatusController.add('disconnected');
  }

  /// Send a chat message
  void sendMessage(String message) {
    if (!_isConnected || _channel == null) {
      debugPrint('ChatWebSocket: Not connected, cannot send message');
      return;
    }

    final messageData = {
      'type': 'chat',
      'message': message,
    };

    _channel!.sink.add(jsonEncode(messageData));
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    if (!_isConnected || _channel == null) {
      return;
    }

    final typingData = {
      'type': 'typing',
      'is_typing': isTyping,
    };

    _channel!.sink.add(jsonEncode(typingData));
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data);

      switch (message['type']) {
        case 'chat':
          _messageController.add(message);
          break;
        case 'typing':
          _typingController.add(message);
          break;
        case 'system':
          // Handle system messages (user joined/left, etc.)
          _messageController.add(message);
          break;
        default:
          debugPrint('ChatWebSocket: Unknown message type: ${message['type']}');
      }
    } catch (e) {
      debugPrint('ChatWebSocket: Error parsing message: $e');
    }
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        // Send a ping-like message
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _stopReconnectTimer();

    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      debugPrint('ChatWebSocket: Attempting to reconnect...');
      await connect(_currentRoom);
    });
  }

  /// Stop reconnection timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Fallback to HTTP polling when WebSocket is unavailable
  void startPolling(String roomId) {
    _stopPolling();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_accessToken == null) return;

      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/chat/messages?room_id=$roomId&limit=20'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );

        if (response.statusCode == 200) {
          final messages = jsonDecode(response.body) as List<dynamic>;
          for (final message in messages) {
            _messageController.add(message as Map<String, dynamic>);
          }
        }
      } catch (e) {
        debugPrint('ChatWebSocket: Polling error: $e');
      }
    });
  }

  /// Stop HTTP polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Update access token (after refresh)
  void updateAccessToken(String newToken) {
    _accessToken = newToken;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStatusController.close();
    _typingController.close();
  }
}

/// Chat API Service (HTTP fallback)
class ChatApiService {
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://gyanvruksh.onrender.com');

  static String? _accessToken;

  static Future<void> initialize() async {
    _accessToken = await AuthStorage.getToken();
  }

  /// Get chat messages via HTTP (fallback)
  static Future<List<Map<String, dynamic>>> getMessages({
    String roomId = 'general',
    int limit = 50,
  }) async {
    if (_accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/messages?room_id=$roomId&limit=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      debugPrint('ChatApiService: Error getting messages: $e');
    }

    return [];
  }

  /// Get available chat rooms
  static Future<List<Map<String, dynamic>>> getRooms() async {
    if (_accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/rooms'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      debugPrint('ChatApiService: Error getting rooms: $e');
    }

    return [];
  }

  /// Acknowledge message receipt
  static Future<bool> acknowledgeMessage(int messageId) async {
    if (_accessToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/messages/$messageId/ack'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ChatApiService: Error acknowledging message: $e');
    }

    return false;
  }

  /// Update access token
  static void updateAccessToken(String newToken) {
    _accessToken = newToken;
  }
}
