import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terse/app_bloc_observer.dart';

/// The type definition for the builder widget.
typedef BootstrapBuilder = FutureOr<Widget> Function(
  SharedPreferencesAsync sharedPreferences,
);

Future<void> bootstrap(BootstrapBuilder builder) async {
  // Add Open Font License (OFL) for Inter and SpaceGrotesk google font
  LicenseRegistry.addLicense(() async* {
    final interLicense = await rootBundle.loadString(
      'assets/licenses/Inter-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], interLicense);

    final spaceGroteskLicense = await rootBundle.loadString(
      'assets/licenses/SpaceGrotesk-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], spaceGroteskLicense);
  });

  // Log all uncaught build phase errors from the framework
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();
  final sharedPreferences = SharedPreferencesAsync();

  runApp(await builder(sharedPreferences));
}
