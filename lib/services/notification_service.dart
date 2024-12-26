import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String _channelKey = 'car_listings_channel';
  static bool _isInitialized = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final ReceivePort _port = ReceivePort();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register port for background actions
      IsolateNameServer.registerPortWithName(
        _port.sendPort,
        'notification_actions',
      );

      // Listen for background actions
      _port.listen((data) async {
        try {
          final receivedAction = ReceivedAction().fromMap(data);
          await _handleActionReceived(receivedAction);
        } catch (e) {
          debugPrint('Failed to handle notification action: $e');
        }
      });

      await AwesomeNotifications().initialize(
        null, // no default icon for now
        [
          NotificationChannel(
            channelKey: _channelKey,
            channelName: 'Car Listings Updates',
            channelDescription: 'Notifications for new car listings',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
          ),
        ],
        debug: kDebugMode,
      );

      await _requestPermissions();
      await _setListeners();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      // Don't rethrow - app should work even without notifications
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      await AwesomeNotifications()
          .isNotificationAllowed()
          .then((isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int? newListingsCount,
  }) async {
    try {
      await initialize(); // Ensure initialized before showing notification

      if (!_isInitialized) {
        debugPrint('Cannot show notification - service not initialized');
        return;
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          channelKey: _channelKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'type': 'new_listings',
            'count': newListingsCount?.toString() ?? '0',
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        ),
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  static Future<void> _setListeners() async {
    try {
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      );
    } catch (e) {
      debugPrint('Failed to set notification listeners: $e');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction received) async {
    try {
      if (!_isInitialized) {
        SendPort? uiSendPort =
            IsolateNameServer.lookupPortByName('notification_actions');
        if (uiSendPort != null) {
          uiSendPort.send(received.toMap());
          return;
        }
      }
      await _handleActionReceived(received);
    } catch (e) {
      debugPrint('Failed to handle notification action: $e');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.title}');
  }

  static Future<void> _handleActionReceived(ReceivedAction received) async {
    try {
      if (received.actionType == ActionType.Default &&
          received.payload?['type'] == 'new_listings') {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/car-listings',
          (route) => false,
          arguments: {
            'showNewestFirst': true,
            'timestamp':
                int.tryParse(received.payload?['timestamp'] ?? '0') ?? 0,
          },
        );
      }
    } catch (e) {
      debugPrint('Failed to handle notification action: $e');
    }
  }
}
