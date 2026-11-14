import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:shared_preferences_storage/shared_preferences_storage.dart';
import 'package:terse/app/app.dart';
import 'package:terse/bootstrap.dart';

Future<void> main() async {
  await bootstrap((sharedPreferences) {
    final sharedPreferencesStorage = SharedPreferencesStorage(
      sharedPreferences: sharedPreferences,
    );

    final onboardingRepository = OnboardingRepository(
      storage: sharedPreferencesStorage,
    );

    return App(onboardingRepository: onboardingRepository);
  });
}
