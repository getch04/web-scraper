import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settings_isar.dart';
import '../services/database_service.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  final _isar = DatabaseService.instance;

  @override
  Stream<SettingsIsar> build() {
    return _isar.settingsIsars.watchObject(0, fireImmediately: true).map(
          (settings) => settings ?? SettingsIsar(),
        );
  }

  Future<void> updateSettings(SettingsIsar settings) async {
    await _isar.writeTxn(() async {
      await _isar.settingsIsars.put(settings.copyWith(id: 0));
    });
  }

  Future<void> toggleNotifications(bool enabled) async {
    final settings = await _isar.settingsIsars.get(0) ?? SettingsIsar();
    await updateSettings(settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateFrequency(NotificationFrequency frequency) async {
    final settings = await _isar.settingsIsars.get(0) ?? SettingsIsar();
    await updateSettings(settings.copyWith(frequency: frequency));
  }
}
