import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String _channelKey = 'car_listings_channel';
  static bool _isInitialized = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final ReceivePort _port = ReceivePort();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Register port for background actions
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'notification_actions',
    );

    // Listen for background actions
    _port.listen((data) async {
      final receivedAction = ReceivedAction().fromMap(data);
      await _handleActionReceived(receivedAction);
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
      debug: true,
    );

    await _requestPermissions();
    await _setListeners();
    _isInitialized = true;
  }

  static Future<void> _requestPermissions() async {
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await initialize(); // Ensure initialized before showing notification

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> _setListeners() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction received) async {
    if (!_isInitialized) {
      SendPort? uiSendPort =
          IsolateNameServer.lookupPortByName('notification_actions');
      if (uiSendPort != null) {
        uiSendPort.send(received.toMap());
        return;
      }
    }
    await _handleActionReceived(received);
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
    // Handle notification actions here
    // For example, navigate to a specific page when notification is tapped
    if (received.actionType == ActionType.Default) {
      navigatorKey.currentState?.pushNamed(
        '/notification-details',
        arguments: received,
      );
    }
  }
}
