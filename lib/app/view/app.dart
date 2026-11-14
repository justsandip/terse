import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/counter/counter.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

class App extends StatelessWidget {
  const new({required this._onboardingRepository, super.key});

  final OnboardingRepository _onboardingRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: _onboardingRepository)],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: const TerseTheme().themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CounterPage(),
    );
  }
}
