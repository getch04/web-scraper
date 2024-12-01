import 'package:isar/isar.dart';

part 'settings_isar.g.dart';

@collection
class SettingsIsar {
  Id? id;

  // Notification Settings
  bool notificationsEnabled;

  // Notification Time Window
  @enumerated
  NotificationFrequency frequency;

  SettingsIsar({
    this.notificationsEnabled = true,
    this.frequency = NotificationFrequency.hourly,
    this.id = Isar.autoIncrement,
  });

  SettingsIsar copyWith({
    final bool? notificationsEnabled,
    final NotificationFrequency? frequency,
    final int? quietHoursStart,
    final int? quietHoursEnd,
    final bool? quietHoursEnabled,
    final Id? id,
  }) {
    return SettingsIsar(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      frequency: frequency ?? this.frequency,
      id: id ?? this.id,
    );
  }
}

enum NotificationFrequency {
  minutes15,
  minutes30,
  minutes45,
  hourly,
  hours2,
  hours4,
  hours8,
  daily,
}

extension NotificationFrequencyExtension on NotificationFrequency {
  String get displayName {
    switch (this) {
      case NotificationFrequency.minutes15:
        return '15 Minutes';
      case NotificationFrequency.minutes30:
        return '30 Minutes';
      case NotificationFrequency.minutes45:
        return '45 Minutes';
      case NotificationFrequency.hourly:
        return 'Hourly';
      case NotificationFrequency.hours2:
        return '2 Hours';
      case NotificationFrequency.hours4:
        return '4 Hours';
      case NotificationFrequency.hours8:
        return '8 Hours';
      case NotificationFrequency.daily:
        return 'Daily';
    }
  }

  Duration get duration {
    switch (this) {
      case NotificationFrequency.minutes15:
        return const Duration(minutes: 15);
      case NotificationFrequency.minutes30:
        return const Duration(minutes: 30);
      case NotificationFrequency.minutes45:
        return const Duration(minutes: 45);
      case NotificationFrequency.hourly:
        return const Duration(hours: 1);
      case NotificationFrequency.hours2:
        return const Duration(hours: 2);
      case NotificationFrequency.hours4:
        return const Duration(hours: 4);
      case NotificationFrequency.hours8:
        return const Duration(hours: 8);
      case NotificationFrequency.daily:
        return const Duration(hours: 24);
    }
  }
}
