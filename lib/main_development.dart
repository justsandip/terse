import 'package:metrics_repository/metrics_repository.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:shared_preferences_storage/shared_preferences_storage.dart';
import 'package:terse/app/app.dart';
import 'package:terse/bootstrap.dart';

Future<void> main() async {
  await bootstrap((sharedPreferences, localDatabase) {
    final sharedPreferencesStorage = SharedPreferencesStorage(
      sharedPreferences: sharedPreferences,
    );

    final onboardingRepository = OnboardingRepository(
      storage: sharedPreferencesStorage,
    );

    final metricsRepository = MetricsRepository(database: localDatabase);

    return App(
      onboardingRepository: onboardingRepository,
      metricsRepository: metricsRepository,
    );
  });
}
