import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

class _MockMetricsRepository extends Mock implements MetricsRepository;

void main() {
  group(SetupPage, () {
    testWidgets('provides a SetupBloc to SetupView', (tester) async {
      final appCubit = _MockAppCubit();
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: const AppState(),
      );

      await tester.pumpWidget(
        RepositoryProvider<MetricsRepository>.value(
          value: _MockMetricsRepository(),
          child: BlocProvider<AppCubit>.value(
            value: appCubit,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SetupPage(),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(SetupView));

      expect(find.byType(SetupView), findsOneWidget);
      expect(context.read<SetupBloc>(), isA<SetupBloc>());
    });
  });
}
