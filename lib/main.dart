import 'dart:async';

import 'package:car_web_scrapepr/car_listing_screen.dart';
import 'package:car_web_scrapepr/core/theme.dart';
import 'package:car_web_scrapepr/providers/settings_provider.dart';
import 'package:car_web_scrapepr/services/database_service.dart';
import 'package:car_web_scrapepr/services/notification_service.dart';
import 'package:car_web_scrapepr/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await DatabaseService.initialize();
  await TrialService.init();

  Timer.periodic(const Duration(minutes: 10), (timer) {
    NotificationService.showNotification(
      title: 'Test Notification',
      body: 'This is a test notification sent at ${DateTime.now().toString()}',
    );
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Flutter Demo',
      home: const CarListingPage(),
      theme: AppTheme.theme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routes: {
        '/notification-details': (context) =>
            const CarListingPage(), // Replace with your notification details page
      },
    );
  }
}
