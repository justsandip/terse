import 'dart:async';

import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/app/app.dart';
import 'package:terse/app/router/router.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

class App extends StatelessWidget {
  const new({
    required this._onboardingRepository,
    required this._metricsRepository,
    required this._entriesRepository,
    super.key,
  });

  final OnboardingRepository _onboardingRepository;
  final MetricsRepository _metricsRepository;
  final EntriesRepository _entriesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _onboardingRepository),
        RepositoryProvider.value(value: _metricsRepository),
        RepositoryProvider.value(value: _entriesRepository),
      ],
      child: BlocProvider<AppCubit>(
        create: (context) {
          final cubit = AppCubit(
            onboardingRepository: context.read<OnboardingRepository>(),
          );
          unawaited(cubit.fetchOnboardingCompleted());
          return cubit;
        },
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const new({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(appCubit: context.read<AppCubit>());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: const TerseTheme().themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _appRouter.router,
    );
  }
}
