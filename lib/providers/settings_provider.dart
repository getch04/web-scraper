import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings_isar.dart';
import '../services/database_service.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  final _isar = DatabaseService.instance;

  @override
  Stream<SettingsIsar> build() async* {
    final existingSettings = await _isar.settingsIsars.get(0);
    if (existingSettings == null) {
      await _isar.writeTxn(() async {
        await _isar.settingsIsars.put(SettingsIsar(
          id: 0,
          notificationsEnabled: true,
          frequencyValue: 1,
          frequencyUnit: TimeUnit.hours,
        ));
      });
    }

    yield* _isar.settingsIsars.watchObject(0, fireImmediately: true).map(
          (settings) => settings ?? SettingsIsar(id: 0),
        );
  }

  Future<void> updateSettings(SettingsIsar settings) async {
    await _isar.writeTxn(() async {
      await _isar.settingsIsars.put(settings.copyWith(id: 0));
    });
  }

  Future<void> toggleNotifications(bool enabled) async {
    final settings = await _isar.settingsIsars.get(0) ?? SettingsIsar(id: 0);
    await updateSettings(settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateFrequencyValue(int value) async {
    final settings = await _isar.settingsIsars.get(0) ?? SettingsIsar(id: 0);
    await updateSettings(settings.copyWith(frequencyValue: value));
  }

  Future<void> updateFrequencyUnit(TimeUnit unit) async {
    final settings = await _isar.settingsIsars.get(0) ?? SettingsIsar(id: 0);
    await updateSettings(settings.copyWith(frequencyUnit: unit));
  }
}
