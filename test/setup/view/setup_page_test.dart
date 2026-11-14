import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group(SetupPage, () {
    testWidgets('provides a SetupCubit to SetupView', (tester) async {
      final appCubit = _MockAppCubit();
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: const AppState(),
      );

      await tester.pumpWidget(
        BlocProvider<AppCubit>.value(
          value: appCubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SetupPage(),
          ),
        ),
      );

      final context = tester.element(find.byType(SetupView));

      expect(find.byType(SetupView), findsOneWidget);
      expect(context.read<SetupCubit>(), isA<SetupCubit>());
    });
  });
}
