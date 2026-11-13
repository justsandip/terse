import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

class _MockStorage extends Mock implements Storage;

void main() {
  group(OnboardingRepository, () {
    const key = OnboardingRepository.completedKey;

    late Storage storage;
    late OnboardingRepository repository;

    setUp(() {
      storage = _MockStorage();
      repository = OnboardingRepository(storage: storage);
    });

    group('fetchOnboardingCompleted', () {
      test('returns false when nothing is stored', () async {
        when(() => storage.read(key: key)).thenAnswer((_) async => null);

        expect(await repository.fetchOnboardingCompleted(), isFalse);
        verify(() => storage.read(key: key)).called(1);
      });

      test('returns false when false is stored', () async {
        when(() => storage.read(key: key)).thenAnswer((_) async => 'false');

        expect(await repository.fetchOnboardingCompleted(), isFalse);
      });

      test('returns true when true is stored', () async {
        when(() => storage.read(key: key)).thenAnswer((_) async => 'true');

        expect(await repository.fetchOnboardingCompleted(), isTrue);
      });

      test(
        'throws FetchOnboardingCompletedFailure when reading fails',
        () async {
          final exception = StorageReadException('oops', StackTrace.current);
          when(() => storage.read(key: key)).thenThrow(exception);

          await expectLater(
            repository.fetchOnboardingCompleted(),
            throwsA(
              isA<FetchOnboardingCompletedFailure>().having(
                (f) => f.error,
                'error',
                exception,
              ),
            ),
          );
        },
      );
    });

    group('setOnboardingCompleted', () {
      test('stores true when completed', () async {
        when(() => storage.write(key: key, value: 'true'))
            .thenAnswer((_) async {});

        await repository.setOnboardingCompleted(completed: true);

        verify(() => storage.write(key: key, value: 'true')).called(1);
      });

      test('stores false when not completed', () async {
        when(() => storage.write(key: key, value: 'false'))
            .thenAnswer((_) async {});

        await repository.setOnboardingCompleted(completed: false);

        verify(() => storage.write(key: key, value: 'false')).called(1);
      });

      test('throws SetOnboardingCompletedFailure when saving fails', () async {
        final exception = StorageWriteException('oops', StackTrace.current);
        when(() => storage.write(key: key, value: 'true')).thenThrow(exception);

        await expectLater(
          repository.setOnboardingCompleted(completed: true),
          throwsA(
            isA<SetOnboardingCompletedFailure>().having(
              (f) => f.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });
  });
}
