import 'dart:convert';

import 'package:local_database/local_database.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLocalDatabase extends Mock implements LocalDatabase;

void main() {
  final now = DateTime.utc(2026, 11, 15, 12);
  final earlier = DateTime.utc(2026, 11);

  MetricRow row({
    required String key,
    String kind = 'scale',
    String? unit,
    double? minValue = 1,
    double? maxValue = 5,
    String? choices,
    double? stepValue,
    double? startValue,
    int position = 0,
    DateTime? archivedAt,
    DateTime? deletedAt,
  }) {
    return MetricRow(
      id: key,
      key: key,
      kind: kind,
      unit: unit,
      minValue: minValue,
      maxValue: maxValue,
      choices: choices,
      stepValue: stepValue,
      startValue: startValue,
      position: position,
      archivedAt: archivedAt,
      createdAt: earlier,
      updatedAt: earlier,
      deletedAt: deletedAt,
    );
  }

  group(MetricsFailure, () {
    test('toString includes the type and the error', () {
      const failure = FetchMetricsFailure('boom');

      expect(failure.toString(), equals('FetchMetricsFailure: boom'));
    });
  });

  group(MetricsRepository, () {
    late LocalDatabase database;
    late MetricsRepository repository;

    setUpAll(() {
      registerFallbackValue(<MetricRow>[]);
    });

    setUp(() {
      database = _MockLocalDatabase();
      repository = MetricsRepository(database: database, now: () => now);
      when(() => database.fetchMetrics()).thenAnswer((_) async => []);
      when(() => database.fetchAllMetrics()).thenAnswer((_) async => []);
      when(() => database.upsertMetrics(any())).thenAnswer((_) async {});
    });

    List<MetricRow> savedRows() {
      final captured = verify(() => database.upsertMetrics(captureAny()))
          .captured;
      return captured.single as List<MetricRow>;
    }

    group('fetchMetrics', () {
      test('returns an empty list when nothing is saved', () async {
        expect(await repository.fetchMetrics(), isEmpty);
      });

      test('maps the rows to metric definitions', () async {
        when(() => database.fetchMetrics()).thenAnswer(
          (_) async => [
            row(
              key: 'sleep_hours',
              kind: 'number',
              unit: 'hours',
              minValue: 0,
              maxValue: 16,
              stepValue: 0.5,
              startValue: 7,
            ),
            row(key: 'mood'),
            row(
              key: 'exercise_type',
              kind: 'choice',
              minValue: null,
              maxValue: null,
              choices: jsonEncode(['none', 'walk']),
            ),
          ],
        );

        expect(
          await repository.fetchMetrics(),
          equals([
            MetricCatalog.sleepHours,
            MetricCatalog.mood,
            const MetricDefinition(
              key: 'exercise_type',
              kind: MetricKind.choice,
              choices: ['none', 'walk'],
            ),
          ]),
        );
      });

      test('throws FetchMetricsFailure when the database fails', () async {
        when(() => database.fetchMetrics()).thenThrow(Exception('oops'));

        await expectLater(
          repository.fetchMetrics(),
          throwsA(isA<FetchMetricsFailure>()),
        );
      });

      test('throws FetchMetricsFailure for an unknown stored kind', () async {
        when(() => database.fetchMetrics())
            .thenAnswer((_) async => [row(key: 'x', kind: 'nope')]);

        await expectLater(
          repository.fetchMetrics(),
          throwsA(isA<FetchMetricsFailure>()),
        );
      });

      test('throws FetchMetricsFailure for invalid stored choices', () async {
        when(() => database.fetchMetrics())
            .thenAnswer((_) async => [row(key: 'x', choices: 'oops')]);

        await expectLater(
          repository.fetchMetrics(),
          throwsA(isA<FetchMetricsFailure>()),
        );
      });
    });

    group('saveMetrics', () {
      test('writes the chosen metrics in order', () async {
        await repository.saveMetrics([
          MetricCatalog.energy,
          MetricCatalog.sleepHours,
          MetricCatalog.exerciseType,
        ]);

        final rows = savedRows();
        final energy = rows[0];
        final sleepHours = rows[1];
        final exerciseType = rows[2];

        expect(
          rows.map((r) => r.id),
          equals(['energy', 'sleep_hours', 'exercise_type']),
        );
        expect(rows.map((r) => r.position), equals([0, 1, 2]));
        expect(energy.kind, equals('scale'));
        expect(energy.unit, isNull);
        expect(energy.minValue, equals(1));
        expect(energy.maxValue, equals(5));
        expect(energy.choices, isNull);
        expect(sleepHours.kind, equals('number'));
        expect(sleepHours.unit, equals('hours'));
        expect(sleepHours.maxValue, equals(16));
        expect(sleepHours.stepValue, equals(0.5));
        expect(sleepHours.startValue, equals(7));
        expect(energy.stepValue, isNull);
        expect(energy.startValue, isNull);
        expect(exerciseType.kind, equals('choice'));
        expect(
          exerciseType.choices,
          equals(jsonEncode(MetricCatalog.exerciseType.choices)),
        );
      });

      test('stamps new metrics with the current time', () async {
        await repository.saveMetrics([MetricCatalog.mood]);

        final saved = savedRows().single;

        expect(saved.createdAt, equals(now));
        expect(saved.updatedAt, equals(now));
        expect(saved.archivedAt, isNull);
        expect(saved.deletedAt, isNull);
      });

      test('keeps the creation time of a metric that already exists', () async {
        when(() => database.fetchAllMetrics())
            .thenAnswer((_) async => [row(key: 'mood')]);

        await repository.saveMetrics([MetricCatalog.mood]);

        final saved = savedRows().single;

        expect(saved.createdAt, equals(earlier));
        expect(saved.updatedAt, equals(now));
      });

      test('brings back an archived metric', () async {
        when(() => database.fetchAllMetrics())
            .thenAnswer((_) async => [row(key: 'mood', archivedAt: earlier)]);

        await repository.saveMetrics([MetricCatalog.mood]);

        expect(savedRows().single.archivedAt, isNull);
      });

      test('archives a metric that is no longer chosen', () async {
        when(() => database.fetchAllMetrics()).thenAnswer(
          (_) async => [
            row(key: 'mood', position: 3, stepValue: 2, startValue: 3),
            row(key: 'energy'),
          ],
        );

        await repository.saveMetrics([MetricCatalog.energy]);

        final rows = savedRows();
        final mood = rows.singleWhere((r) => r.key == 'mood');

        expect(rows, hasLength(2));
        expect(mood.archivedAt, equals(now));
        expect(mood.updatedAt, equals(now));
        expect(mood.createdAt, equals(earlier));
        expect(mood.position, equals(3));
        expect(mood.stepValue, equals(2));
        expect(mood.startValue, equals(3));
      });

      test('leaves archived and deleted metrics alone', () async {
        when(() => database.fetchAllMetrics()).thenAnswer(
          (_) async => [
            row(key: 'mood', archivedAt: earlier),
            row(key: 'stress', deletedAt: earlier),
          ],
        );

        await repository.saveMetrics([]);

        expect(savedRows(), isEmpty);
      });

      test('uses the current UTC time by default', () async {
        await MetricsRepository(database: database)
            .saveMetrics([MetricCatalog.mood]);

        expect(savedRows().single.updatedAt.isUtc, isTrue);
      });

      test('throws SaveMetricsFailure when reading metrics fails', () async {
        when(() => database.fetchAllMetrics()).thenThrow(Exception('oops'));

        await expectLater(
          repository.saveMetrics([MetricCatalog.mood]),
          throwsA(isA<SaveMetricsFailure>()),
        );
      });

      test('throws SaveMetricsFailure when writing fails', () async {
        when(() => database.upsertMetrics(any())).thenThrow(Exception('oops'));

        await expectLater(
          repository.saveMetrics([MetricCatalog.mood]),
          throwsA(isA<SaveMetricsFailure>()),
        );
      });
    });
  });
}
