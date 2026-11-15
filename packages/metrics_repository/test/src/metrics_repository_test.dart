import 'dart:convert';

import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

class _MockStorage extends Mock implements Storage;

void main() {
  group(MetricsRepository, () {
    const key = MetricsRepository.metricsKey;

    late Storage storage;
    late MetricsRepository repository;

    setUp(() {
      storage = _MockStorage();
      repository = MetricsRepository(storage: storage);
    });

    group('fetchMetrics', () {
      test('returns an empty list when nothing is stored', () async {
        when(() => storage.read(key: key)).thenAnswer((_) async => null);

        expect(await repository.fetchMetrics(), isEmpty);
        verify(() => storage.read(key: key)).called(1);
      });

      test('returns the stored metrics', () async {
        final stored = jsonEncode([
          MetricCatalog.sleepHours.toJson(),
          MetricCatalog.mood.toJson(),
        ]);
        when(() => storage.read(key: key)).thenAnswer((_) async => stored);

        expect(
          await repository.fetchMetrics(),
          equals([MetricCatalog.sleepHours, MetricCatalog.mood]),
        );
      });

      test('throws FetchMetricsFailure when reading fails', () async {
        final exception = StorageReadException('oops', StackTrace.current);
        when(() => storage.read(key: key)).thenThrow(exception);

        await expectLater(
          repository.fetchMetrics(),
          throwsA(
            isA<FetchMetricsFailure>().having(
              (failure) => failure.error,
              'error',
              exception,
            ),
          ),
        );
      });

      test('throws FetchMetricsFailure when the value is not JSON', () async {
        when(() => storage.read(key: key)).thenAnswer((_) async => 'oops');

        await expectLater(
          repository.fetchMetrics(),
          throwsA(isA<FetchMetricsFailure>()),
        );
      });

      test('throws FetchMetricsFailure when a metric is malformed', () async {
        final stored = jsonEncode([
          {'key': 'x', 'kind': 'nope'},
        ]);
        when(() => storage.read(key: key)).thenAnswer((_) async => stored);

        await expectLater(
          repository.fetchMetrics(),
          throwsA(isA<FetchMetricsFailure>()),
        );
      });
    });

    group('saveMetrics', () {
      test('stores the metrics as JSON', () async {
        final expected = jsonEncode([MetricCatalog.mood.toJson()]);
        when(() => storage.write(key: key, value: expected))
            .thenAnswer((_) async {});

        await repository.saveMetrics([MetricCatalog.mood]);

        verify(() => storage.write(key: key, value: expected)).called(1);
      });

      test('throws SaveMetricsFailure when writing fails', () async {
        final exception = StorageWriteException('oops', StackTrace.current);
        when(
          () => storage.write(
            key: key,
            value: any(named: 'value'),
          ),
        ).thenThrow(exception);

        await expectLater(
          repository.saveMetrics([MetricCatalog.mood]),
          throwsA(
            isA<SaveMetricsFailure>().having(
              (failure) => failure.error,
              'error',
              exception,
            ),
          ),
        );
      });
    });
  });
}
