import 'package:isar/isar.dart';

part 'settings_isar.g.dart';

@collection
class SettingsIsar {
  Id? id;

  // Notification Settings
  bool notificationsEnabled;

  // Custom notification frequency
  int frequencyValue; // Store the numeric value
  @enumerated
  TimeUnit frequencyUnit; // Store the time unit

  SettingsIsar({
    this.notificationsEnabled = true,
    this.frequencyValue = 1,
    this.frequencyUnit = TimeUnit.hours,
    this.id = Isar.autoIncrement,
  });

  SettingsIsar copyWith({
    final bool? notificationsEnabled,
    final int? frequencyValue,
    final TimeUnit? frequencyUnit,
    final Id? id,
  }) {
    return SettingsIsar(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      frequencyUnit: frequencyUnit ?? this.frequencyUnit,
      id: id ?? this.id,
    );
  }

  @ignore
  Duration get frequency {
    return Duration(
      microseconds: frequencyValue * frequencyUnit.inMicroseconds,
    );
  }
}

enum TimeUnit {
  seconds,
  minutes,
  hours,
  days;

  int get inMicroseconds {
    switch (this) {
      case TimeUnit.seconds:
        return Duration.microsecondsPerSecond;
      case TimeUnit.minutes:
        return Duration.microsecondsPerSecond * 60;
      case TimeUnit.hours:
        return Duration.microsecondsPerSecond * 60 * 60;
      case TimeUnit.days:
        return Duration.microsecondsPerSecond * 60 * 60 * 24;
    }
  }

  String get displayName {
    return switch (this) {
      TimeUnit.seconds => 'Seconds',
      TimeUnit.minutes => 'Minutes',
      TimeUnit.hours => 'Hours',
      TimeUnit.days => 'Days',
    };
  }
}
