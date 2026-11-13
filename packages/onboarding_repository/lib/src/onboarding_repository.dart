import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:storage/storage.dart';

/// {@template onboarding_repository}
/// Repository to manage User Onboarding
/// {@endtemplate}
class OnboardingRepository {
  /// {@macro onboarding_repository}
  const new({required this._storage});

  /// The storage key that holds the onboarding status.
  static const completedKey = '__onboarding_completed_key__';

  final Storage _storage;

  /// Returns whether the user has completed onboarding.
  ///
  /// Returns `false` when no status has been saved yet.
  ///
  /// Throws a [FetchOnboardingCompletedFailure] if reading fails.
  Future<bool> fetchOnboardingCompleted() async {
    try {
      final value = await _storage.read(key: completedKey);
      return value == 'true';
    } on StorageException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchOnboardingCompletedFailure(error),
        stackTrace,
      );
    }
  }

  /// Saves whether the user has completed onboarding.
  ///
  /// Throws a [SetOnboardingCompletedFailure] if saving fails.
  Future<void> setOnboardingCompleted({required bool completed}) async {
    try {
      await _storage.write(key: completedKey, value: '$completed');
    } on StorageException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SetOnboardingCompletedFailure(error),
        stackTrace,
      );
    }
  }
}
