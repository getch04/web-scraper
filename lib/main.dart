import 'dart:async';

import 'package:car_web_scrapepr/car_listing_screen.dart';
import 'package:car_web_scrapepr/core/theme.dart';
import 'package:car_web_scrapepr/providers/settings_provider.dart';
import 'package:car_web_scrapepr/services/background_service.dart';
import 'package:car_web_scrapepr/services/database_service.dart';
import 'package:car_web_scrapepr/services/notification_service.dart';
import 'package:car_web_scrapepr/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> cleanupOldListings() async {
  final listings = await DatabaseService.getExistingListings();
  if (listings.length > 500) {
    await DatabaseService.deleteOldListings(500);
    debugPrint('🧹 Cleaned up ${listings.length - 500} old car listings');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await DatabaseService.initialize();
  await BackgroundService.initialize();

  // Clean up old listings
  await cleanupOldListings();

  // Simulate background fetch every 1 minute for testing
  Timer.periodic(const Duration(seconds: 70), (timer) async {
    debugPrint('🔄 Simulating background fetch...');
    await BackgroundService.handleBackground();
    debugPrint('✅ Background fetch simulation completed');
  });

  await TrialService.init();

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
        '/car-listings': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return const CarListingPage();
        },
      },
    );
  }
}
