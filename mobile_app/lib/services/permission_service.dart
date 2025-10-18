import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Permission Service for handling runtime permissions in Flutter
class PermissionService {
  /// Request internet permission (automatically granted, but good practice to check)
  static Future<bool> requestInternetPermission() async {
    try {
      // Internet permission is granted at install time for normal apps
      // This is mainly for checking if the device has internet capability
      return true;
    } catch (e) {
      print('Error checking internet permission: $e');
      return false;
    }
  }

  /// Request camera permission for file uploads and profile pictures
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request storage permissions for file uploads and downloads
  static Future<bool> requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), use granular permissions
      if (await Permission.photos.request().isGranted ||
          await Permission.videos.request().isGranted) {
        return true;
      }

      // Fallback for older versions
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request microphone permission for audio features
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Request notification permission for push notifications
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Request location permission (optional feature)
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if all required permissions are granted
  static Future<Map<String, bool>> checkAllPermissions() async {
    final Map<String, bool> permissions = {};

    try {
      permissions['internet'] = await requestInternetPermission();
      permissions['camera'] = await Permission.camera.isGranted;
      permissions['storage'] = await Permission.storage.isGranted ||
                              await Permission.photos.isGranted ||
                              await Permission.videos.isGranted;
      permissions['microphone'] = await Permission.microphone.isGranted;
      permissions['notifications'] = await Permission.notification.isGranted;
      permissions['location'] = await Permission.locationWhenInUse.isGranted;

      return permissions;
    } catch (e) {
      print('Error checking permissions: $e');
      return permissions;
    }
  }

  /// Request all required permissions for the app
  static Future<bool> requestAllPermissions() async {
    try {
      // Request essential permissions
      await requestInternetPermission(); // Always granted
      await requestCameraPermission();
      await requestStoragePermission();
      await requestMicrophonePermission();
      await requestNotificationPermission();

      // Check if all essential permissions are granted
      final cameraStatus = await Permission.camera.isGranted;
      final storageStatus = await Permission.storage.isGranted ||
                           await Permission.photos.isGranted ||
                           await Permission.videos.isGranted;

      return cameraStatus && storageStatus;
    } catch (e) {
      print('Error requesting all permissions: $e');
      return false;
    }
  }

  /// Show permission rationale and request permission
  static Future<bool> requestPermissionWithRationale(
    Permission permission,
    String rationale,
  ) async {
    try {
      // Check if permission is permanently denied
      if (await permission.isPermanentlyDenied) {
        // Open app settings
        await openAppSettings();
        return false;
      }

      // Request permission
      final status = await permission.request();

      if (status.isDenied) {
        // Show rationale if needed
        print('Permission denied: $rationale');
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting permission with rationale: $e');
      return false;
    }
  }

  /// Check if permission should show rationale
  static Future<bool> shouldShowRationale(Permission permission) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      print('Error checking rationale: $e');
      return false;
    }
  }

  /// Handle permission denied scenario
  static Future<void> handlePermissionDenied(
    Permission permission,
    String feature,
  ) async {
    try {
      if (await permission.isPermanentlyDenied) {
        // Show message about enabling permission in settings
        print('$feature requires permission. Please enable it in app settings.');
        await openAppSettings();
      } else {
        print('$feature permission was denied');
      }
    } catch (e) {
      print('Error handling permission denied: $e');
    }
  }

  /// Initialize permissions on app startup
  static Future<void> initializePermissions() async {
    try {
      // Initialize permission handler
      await PermissionHandlerWidgetsFlutterBinding.ensureInitialized();

      // Check current permission status
      final permissions = await checkAllPermissions();
      print('Current permission status: $permissions');

      // Request missing essential permissions
      if (!permissions['camera']!) {
        await requestCameraPermission();
      }

      if (!permissions['storage']!) {
        await requestStoragePermission();
      }

      if (!permissions['notifications']!) {
        await requestNotificationPermission();
      }

    } catch (e) {
      print('Error initializing permissions: $e');
    }
  }
}

/// Permission Handler Widgets Flutter Binding
/// Ensures proper initialization of permission handler
class PermissionHandlerWidgetsFlutterBinding {
  static Future<void> ensureInitialized() async {
    try {
      // This ensures that the WidgetsFlutterBinding is initialized
      // before any permission operations
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize permission handler
      await PermissionHandlerWidgetsFlutterBinding._initializePermissionHandler();

    } catch (e) {
      print('Error ensuring permission handler initialization: $e');
    }
  }

  static Future<void> _initializePermissionHandler() async {
    try {
      // Permission handler should be auto-initialized, but we ensure it's ready
      final status = await Permission.camera.status;
      print('Permission handler initialized with camera status: $status');
    } catch (e) {
      print('Error initializing permission handler: $e');
    }
  }
}
