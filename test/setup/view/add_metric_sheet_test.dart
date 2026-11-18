import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';

void main() {
  group(AddMetricSheet, () {
    const metrics = [MetricCatalog.energy, MetricCatalog.sleepHours];

    MetricDefinition? picked;

    setUp(() {
      picked = null;
    });

    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      picked = await showModalBottomSheet<MetricDefinition>(
                        context: context,
                        builder: (context) {
                          return const AddMetricSheet(metrics: metrics);
                        },
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows its title', (tester) async {
      await openSheet(tester);

      expect(find.text('Choose a metric'), findsOneWidget);
    });

    testWidgets('lists each metric with its kind', (tester) async {
      await openSheet(tester);

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.widgetWithText(ListTile, 'Energy'), findsOneWidget);
      expect(find.text('1 to 5'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Sleep hours'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
    });

    testWidgets('returns the metric that is tapped and closes', (tester) async {
      await openSheet(tester);

      await tester.tap(find.widgetWithText(ListTile, 'Sleep hours'));
      await tester.pumpAndSettle();

      expect(picked, equals(MetricCatalog.sleepHours));
      expect(find.byType(AddMetricSheet), findsNothing);
    });
  });
}
