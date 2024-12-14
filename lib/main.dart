import 'dart:io';

import 'package:car_web_scrapepr/car_listing_screen.dart';
import 'package:car_web_scrapepr/core/theme.dart';
import 'package:car_web_scrapepr/providers/settings_provider.dart';
import 'package:car_web_scrapepr/services/background_service.dart';
import 'package:car_web_scrapepr/services/database_service.dart';
import 'package:car_web_scrapepr/services/notification_service.dart';
import 'package:car_web_scrapepr/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Permission.notification.request();
  }
  await NotificationService.initialize();

  await DatabaseService.initialize();
  await BackgroundService.initialize();

  await TrialService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    return MaterialApp(
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
    );
  }
}
