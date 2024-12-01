import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class TrialService {
  static const _installDateKey = 'install_date';
  static const _trialDays = 4;
  // static const _trialDays = 1 / (24 * 60); // 1 minute expressed in days

  static late StreamingSharedPreferences _streamPrefs;

  static Future<void> init() async {
    _streamPrefs = await StreamingSharedPreferences.instance;
  }

  static Stream<bool> watchShouldShowPaywall() async* {
    await init();

    final installDateStream =
        _streamPrefs.getInt(_installDateKey, defaultValue: 0);

    yield* installDateStream.map((installDateMs) {
      if (installDateMs == 0) {
        _setInstallDate();
        return false;
      }

      final installDate = DateTime.fromMillisecondsSinceEpoch(installDateMs);
      final daysSinceInstall =
          DateTime.now().difference(installDate).inMinutes / (24 * 60);
      return daysSinceInstall >= _trialDays;
    });
  }

  static Future<void> _setInstallDate() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _streamPrefs.setInt(_installDateKey, now);
  }
}
