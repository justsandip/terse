import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_storage/shared_preferences_storage.dart';
import 'package:storage/storage.dart';

class _MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync;

void main() {
  group(SharedPreferencesStorage, () {
    const key = 'key';
    const value = 'value';
    final exception = Exception('oops');

    late SharedPreferencesAsync sharedPreferences;
    late SharedPreferencesStorage storage;

    setUp(() {
      sharedPreferences = _MockSharedPreferencesAsync();
      storage = SharedPreferencesStorage(sharedPreferences: sharedPreferences);
    });

    test('is a Storage', () {
      expect(storage, isA<Storage>());
    });

    group('read', () {
      test('returns the stored value', () async {
        when(() => sharedPreferences.getString(key))
            .thenAnswer((_) async => value);

        expect(await storage.read(key: key), equals(value));
        verify(() => sharedPreferences.getString(key)).called(1);
      });

      test('returns null when nothing is stored', () async {
        when(() => sharedPreferences.getString(key))
            .thenAnswer((_) async => null);

        expect(await storage.read(key: key), isNull);
      });

      test('throws StorageReadException when the read fails', () async {
        when(() => sharedPreferences.getString(key)).thenThrow(exception);

        await expectLater(
          storage.read(key: key),
          throwsA(
            isA<StorageReadException>().having(
              (e) => e.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });

    group('write', () {
      test('stores the value under the key', () async {
        when(() => sharedPreferences.setString(key, value))
            .thenAnswer((_) async {});

        await storage.write(key: key, value: value);

        verify(() => sharedPreferences.setString(key, value)).called(1);
      });

      test('throws StorageWriteException when the write fails', () async {
        when(() => sharedPreferences.setString(key, value))
            .thenThrow(exception);

        await expectLater(
          storage.write(key: key, value: value),
          throwsA(
            isA<StorageWriteException>().having(
              (e) => e.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });

    group('delete', () {
      test('removes the value stored under the key', () async {
        when(() => sharedPreferences.remove(key)).thenAnswer((_) async {});

        await storage.delete(key: key);

        verify(() => sharedPreferences.remove(key)).called(1);
      });

      test('throws StorageDeleteException when the delete fails', () async {
        when(() => sharedPreferences.remove(key)).thenThrow(exception);

        await expectLater(
          storage.delete(key: key),
          throwsA(
            isA<StorageDeleteException>().having(
              (e) => e.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });

    group('clear', () {
      test('clears the underlying preferences', () async {
        when(() => sharedPreferences.clear()).thenAnswer((_) async {});

        await storage.clear();

        verify(() => sharedPreferences.clear()).called(1);
      });

      test('throws StorageClearException when the clear fails', () async {
        when(() => sharedPreferences.clear()).thenThrow(exception);

        await expectLater(
          storage.clear(),
          throwsA(
            isA<StorageClearException>().having(
              (e) => e.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });
  });
}
