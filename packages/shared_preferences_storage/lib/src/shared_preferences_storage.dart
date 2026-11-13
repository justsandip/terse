import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/storage.dart';

/// {@template shared_preferences_storage}
/// A [Storage] backed by [SharedPreferencesAsync].
///
/// Suited to small values such as flags and settings.
/// {@endtemplate}
class SharedPreferencesStorage implements Storage {
  /// {@macro shared_preferences_storage}
  const new({required this._sharedPreferences});

  final SharedPreferencesAsync _sharedPreferences;

  @override
  Future<String?> read({required String key}) async {
    try {
      final value = await _sharedPreferences.getString(key);
      return value;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StorageReadException(error, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _sharedPreferences.setString(key, value);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StorageWriteException(error, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _sharedPreferences.remove(key);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StorageDeleteException(error, stackTrace),
        stackTrace,
      );
    }
  }

  /// Removes every preference stored through the shared_preferences plugin,
  /// not only the ones written by this class.
  @override
  Future<void> clear() async {
    try {
      await _sharedPreferences.clear();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StorageClearException(error, stackTrace),
        stackTrace,
      );
    }
  }
}
