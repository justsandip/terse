// For testing purposes
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:entries_repository/entries_repository.dart';
import 'package:local_database/local_database.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLocalDatabase extends Mock implements LocalDatabase;

void main() {
  final now = DateTime.utc(2026, 11, 18, 12);
  final earlier = DateTime.utc(2026, 11);
  final day = DateTime(2026, 11, 18);
  const dayKey = '2026-11-18';

  MetricRow metricRow({
    required String key,
    required String kind,
    double? minValue,
    double? maxValue,
    String? choices,
    DateTime? archivedAt,
    DateTime? deletedAt,
  }) {
    return MetricRow(
      id: key,
      key: key,
      kind: kind,
      minValue: minValue,
      maxValue: maxValue,
      choices: choices,
      position: 0,
      archivedAt: archivedAt,
      createdAt: earlier,
      updatedAt: earlier,
      deletedAt: deletedAt,
    );
  }

  EntryRow entryRow({
    String date = dayKey,
    String? note,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return EntryRow(
      id: date,
      date: date,
      note: note,
      createdAt: createdAt ?? earlier,
      updatedAt: earlier,
      deletedAt: deletedAt,
    );
  }

  EntryValueRow valueRow(
    String metricId, {
    String entryId = dayKey,
    double? numberValue,
    String? textValue,
  }) {
    return EntryValueRow(
      entryId: entryId,
      metricId: metricId,
      numberValue: numberValue,
      textValue: textValue,
    );
  }

  group(EntriesRepository, () {
    late LocalDatabase database;
    late EntriesRepository repository;

    setUpAll(() {
      registerFallbackValue(entryRow());
      registerFallbackValue(<EntryValueRow>[]);
    });

    setUp(() {
      database = _MockLocalDatabase();
      repository = EntriesRepository(database: database, now: () => now);

      when(() => database.fetchAllMetrics()).thenAnswer(
        (_) async => [
          metricRow(
            key: 'sleep_hours',
            kind: 'number',
            minValue: 0,
            maxValue: 16,
          ),
          metricRow(key: 'water', kind: 'number'),
          metricRow(key: 'mood', kind: 'scale', minValue: 1, maxValue: 5),
          metricRow(key: 'gym', kind: 'boolean'),
          metricRow(
            key: 'exercise_type',
            kind: 'choice',
            choices: jsonEncode(['none', 'walk']),
          ),
          metricRow(key: 'no_options', kind: 'choice'),
          metricRow(key: 'reading', kind: 'number', archivedAt: earlier),
          metricRow(key: 'stress', kind: 'scale', deletedAt: earlier),
        ],
      );
      when(() => database.fetchEntryByDate(any()))
          .thenAnswer((_) async => null);
      when(() => database.fetchEntryByDate(any(), includeDeleted: true))
          .thenAnswer((_) async => null);
      when(() => database.fetchEntryValues(any())).thenAnswer((_) async => []);
      when(() => database.saveEntry(any(), any())).thenAnswer((_) async {});
    });

    ({EntryRow entry, List<EntryValueRow> values}) saved() {
      final captured = verify(
        () => database.saveEntry(captureAny(), captureAny()),
      ).captured;
      return (
        entry: captured[0] as EntryRow,
        values: captured[1] as List<EntryValueRow>,
      );
    }

    group('fetchEntry', () {
      test('returns null when the day has no entry', () async {
        expect(await repository.fetchEntry(day), isNull);
      });

      test('asks for the day as year-month-day, zero padded', () async {
        await repository.fetchEntry(DateTime(2026, 1, 5, 23, 59));

        verify(() => database.fetchEntryByDate('2026-01-05')).called(1);
      });

      test('maps the saved rows to an entry', () async {
        when(() => database.fetchEntryByDate(any()))
            .thenAnswer((_) async => entryRow(note: 'Good run'));
        when(() => database.fetchEntryValues(dayKey)).thenAnswer(
          (_) async => [
            valueRow('sleep_hours', numberValue: 6.5),
            valueRow('mood', numberValue: 4),
            valueRow('gym', numberValue: 1),
            valueRow('exercise_type', textValue: 'walk'),
          ],
        );

        final entry = await repository.fetchEntry(day);

        expect(
          entry,
          equals(
            Entry(
              date: day,
              note: 'Good run',
              values: const {
                'sleep_hours': NumberValue(6.5),
                'mood': NumberValue(4),
                'gym': BooleanValue(true),
                'exercise_type': ChoiceValue('walk'),
              },
            ),
          ),
        );
      });

      test('reads a stored zero as no', () async {
        when(() => database.fetchEntryByDate(any()))
            .thenAnswer((_) async => entryRow());
        when(() => database.fetchEntryValues(dayKey))
            .thenAnswer((_) async => [valueRow('gym', numberValue: 0)]);

        final entry = await repository.fetchEntry(day);

        expect(entry?.values['gym'], equals(const BooleanValue(false)));
      });

      test('keeps the values of an archived metric', () async {
        when(() => database.fetchEntryByDate(any()))
            .thenAnswer((_) async => entryRow());
        when(() => database.fetchEntryValues(dayKey))
            .thenAnswer((_) async => [valueRow('reading', numberValue: 30)]);

        final entry = await repository.fetchEntry(day);

        expect(entry?.values['reading'], equals(const NumberValue(30)));
      });

      test('throws FetchEntryFailure when the database fails', () async {
        when(() => database.fetchEntryByDate(any())).thenThrow(Exception('x'));

        await expectLater(
          repository.fetchEntry(day),
          throwsA(isA<FetchEntryFailure>()),
        );
      });

      test('throws FetchEntryFailure for a stored unknown kind', () async {
        when(() => database.fetchEntryByDate(any()))
            .thenAnswer((_) async => entryRow());
        when(() => database.fetchAllMetrics())
            .thenAnswer((_) async => [metricRow(key: 'mood', kind: 'nope')]);
        when(() => database.fetchEntryValues(dayKey))
            .thenAnswer((_) async => [valueRow('mood', numberValue: 3)]);

        await expectLater(
          repository.fetchEntry(day),
          throwsA(isA<FetchEntryFailure>()),
        );
      });
    });

    group('fetchEntries', () {
      final from = DateTime(2026, 11, 16);
      final to = DateTime(2026, 11, 18);

      setUp(() {
        when(() => database.fetchEntriesBetween(any(), any()))
            .thenAnswer((_) async => []);
        when(() => database.fetchValuesBetween(any(), any()))
            .thenAnswer((_) async => []);
      });

      test(
        'returns nothing, and reads no more, when the range is empty',
        () async {
          expect(await repository.fetchEntries(from: from, to: to), isEmpty);

          verifyNever(() => database.fetchValuesBetween(any(), any()));
          verifyNever(() => database.fetchAllMetrics());
        },
      );

      test('asks for the days as year-month-day, zero padded', () async {
        await repository.fetchEntries(
          from: DateTime(2026, 1, 5, 23, 59),
          to: DateTime(2026, 2, 1),
        );

        verify(() => database.fetchEntriesBetween('2026-01-05', '2026-02-01'))
            .called(1);
      });

      test(
        'maps each day to an entry with its own values, oldest first',
        () async {
          when(() => database.fetchEntriesBetween(any(), any())).thenAnswer(
            (_) async => [
              entryRow(date: '2026-11-16', note: 'Slow start'),
              entryRow(date: '2026-11-18'),
            ],
          );
          when(() => database.fetchValuesBetween(any(), any())).thenAnswer(
            (_) async => [
              valueRow('mood', entryId: '2026-11-18', numberValue: 4),
              valueRow('sleep_hours', entryId: '2026-11-16', numberValue: 6),
              valueRow('reading', entryId: '2026-11-18', numberValue: 30),
            ],
          );

          final entries = await repository.fetchEntries(from: from, to: to);

          expect(
            entries,
            equals([
              Entry(
                date: DateTime(2026, 11, 16),
                note: 'Slow start',
                values: const {'sleep_hours': NumberValue(6)},
              ),
              Entry(
                date: DateTime(2026, 11, 18),
                values: const {
                  'mood': NumberValue(4),
                  'reading': NumberValue(30),
                },
              ),
            ]),
          );
        },
      );

      test('returns a day that has no values as an empty entry', () async {
        when(() => database.fetchEntriesBetween(any(), any())).thenAnswer(
          (_) async => [entryRow(date: '2026-11-17', note: 'Rest day')],
        );

        final entries = await repository.fetchEntries(from: from, to: to);

        expect(
          entries,
          equals([Entry(date: DateTime(2026, 11, 17), note: 'Rest day')]),
        );
      });

      test(
        'reads the range in one query for entries and one for values',
        () async {
          when(() => database.fetchEntriesBetween(any(), any())).thenAnswer(
            (_) async => [
              entryRow(date: '2026-11-16'),
              entryRow(date: '2026-11-17'),
              entryRow(date: '2026-11-18'),
            ],
          );

          await repository.fetchEntries(from: from, to: to);

          verify(() => database.fetchEntriesBetween(any(), any())).called(1);
          verify(() => database.fetchValuesBetween(any(), any())).called(1);
          verifyNever(() => database.fetchEntryValues(any()));
        },
      );

      test('throws FetchEntryFailure when the database fails', () async {
        when(() => database.fetchEntriesBetween(any(), any()))
            .thenThrow(Exception('x'));

        await expectLater(
          repository.fetchEntries(from: from, to: to),
          throwsA(isA<FetchEntryFailure>()),
        );
      });

      test('throws FetchEntryFailure for a stored unknown kind', () async {
        when(() => database.fetchEntriesBetween(any(), any()))
            .thenAnswer((_) async => [entryRow(date: '2026-11-18')]);
        when(() => database.fetchValuesBetween(any(), any())).thenAnswer(
          (_) async => [
            valueRow('mood', entryId: '2026-11-18', numberValue: 3),
          ],
        );
        when(() => database.fetchAllMetrics())
            .thenAnswer((_) async => [metricRow(key: 'mood', kind: 'nope')]);

        await expectLater(
          repository.fetchEntries(from: from, to: to),
          throwsA(isA<FetchEntryFailure>()),
        );
      });
    });

    group('saveEntry', () {
      test('saves the day with the current time', () async {
        await repository.saveEntry(Entry(date: day, note: 'Good run'));

        final (:entry, :values) = saved();

        expect(entry.id, equals(dayKey));
        expect(entry.date, equals(dayKey));
        expect(entry.note, equals('Good run'));
        expect(entry.createdAt, equals(now));
        expect(entry.updatedAt, equals(now));
        expect(entry.deletedAt, isNull);
        expect(values, isEmpty);
      });

      test('saves each kind of value in its own column', () async {
        await repository.saveEntry(
          Entry(
            date: day,
            values: const {
              'sleep_hours': NumberValue(6.5),
              'mood': NumberValue(4),
              'gym': BooleanValue(true),
              'exercise_type': ChoiceValue('walk'),
            },
          ),
        );

        final (:values, entry: _) = saved();
        EntryValueRow of(String id) =>
            values.singleWhere((v) => v.metricId == id);

        expect(values, hasLength(4));
        expect(of('sleep_hours').numberValue, equals(6.5));
        expect(of('sleep_hours').textValue, isNull);
        expect(of('mood').numberValue, equals(4));
        expect(of('gym').numberValue, equals(1));
        expect(of('exercise_type').textValue, equals('walk'));
        expect(of('exercise_type').numberValue, isNull);
        expect(values.every((v) => v.entryId == dayKey), isTrue);
      });

      test('saves a no as zero', () async {
        await repository.saveEntry(
          Entry(date: day, values: const {'gym': BooleanValue(false)}),
        );

        expect(saved().values.single.numberValue, equals(0));
      });

      test('accepts a number that has no limits', () async {
        await repository.saveEntry(
          Entry(date: day, values: const {'water': NumberValue(2000)}),
        );

        expect(saved().values.single.numberValue, equals(2000));
      });

      test('accepts values at the limits', () async {
        await repository.saveEntry(
          Entry(
            date: day,
            values: const {
              'sleep_hours': NumberValue(16),
              'mood': NumberValue(1),
            },
          ),
        );

        expect(saved().values, hasLength(2));
      });

      test('trims the note', () async {
        await repository.saveEntry(Entry(date: day, note: '  hello  '));

        expect(saved().entry.note, equals('hello'));
      });

      test('saves a blank note as no note', () async {
        await repository.saveEntry(Entry(date: day, note: '   '));

        expect(saved().entry.note, isNull);
      });

      test('keeps the creation time of a day that already exists', () async {
        when(() => database.fetchEntryByDate(any(), includeDeleted: true))
            .thenAnswer((_) async => entryRow(deletedAt: earlier));

        await repository.saveEntry(Entry(date: day));

        final (:entry, values: _) = saved();

        expect(entry.createdAt, equals(earlier));
        expect(entry.updatedAt, equals(now));
        expect(entry.deletedAt, isNull);
      });

      test('uses the current UTC time by default', () async {
        await EntriesRepository(database: database).saveEntry(Entry(date: day));

        expect(saved().entry.updatedAt.isUtc, isTrue);
      });

      group('rejects', () {
        Future<void> expectInvalid(Entry entry) async {
          await expectLater(
            repository.saveEntry(entry),
            throwsA(isA<InvalidEntryFailure>()),
          );
          verifyNever(() => database.saveEntry(any(), any()));
        }

        Entry withValue(String key, MetricValue value) {
          return Entry(date: day, values: {key: value});
        }

        test('a metric that does not exist', () {
          return expectInvalid(withValue('nope', const NumberValue(1)));
        });

        test('an archived metric', () {
          return expectInvalid(withValue('reading', const NumberValue(1)));
        });

        test('a deleted metric', () {
          return expectInvalid(withValue('stress', const NumberValue(1)));
        });

        test('a number that is not finite', () {
          return expectInvalid(
            withValue('water', const NumberValue(double.nan)),
          );
        });

        test('a number below its minimum', () {
          return expectInvalid(withValue('sleep_hours', const NumberValue(-1)));
        });

        test('a number above its maximum', () {
          return expectInvalid(withValue('sleep_hours', const NumberValue(17)));
        });

        test('a scale value that is not whole', () {
          return expectInvalid(withValue('mood', const NumberValue(3.5)));
        });

        test('a scale value out of range', () {
          return expectInvalid(withValue('mood', const NumberValue(6)));
        });

        test('a choice that is not an option', () {
          return expectInvalid(
            withValue('exercise_type', const ChoiceValue('swim')),
          );
        });

        test('a choice metric that has no options', () {
          return expectInvalid(
            withValue('no_options', const ChoiceValue('walk')),
          );
        });

        test('a value of the wrong type for its metric', () {
          return expectInvalid(withValue('mood', const BooleanValue(true)));
        });

        test('one bad value among good ones', () {
          return expectInvalid(
            Entry(
              date: day,
              values: const {
                'mood': NumberValue(4),
                'sleep_hours': NumberValue(99),
              },
            ),
          );
        });
      });

      test('throws SaveEntryFailure when reading metrics fails', () async {
        when(() => database.fetchAllMetrics()).thenThrow(Exception('x'));

        await expectLater(
          repository.saveEntry(Entry(date: day)),
          throwsA(isA<SaveEntryFailure>()),
        );
      });

      test('throws SaveEntryFailure when writing fails', () async {
        when(() => database.saveEntry(any(), any())).thenThrow(Exception('x'));

        await expectLater(
          repository.saveEntry(Entry(date: day)),
          throwsA(isA<SaveEntryFailure>()),
        );
      });
    });

    group('deleteEntry', () {
      test('erases the note and values and marks the day deleted', () async {
        when(
          () => database.fetchEntryByDate(any()),
        ).thenAnswer((_) async => entryRow(note: 'secret', createdAt: earlier));

        await repository.deleteEntry(day);

        final (:entry, :values) = saved();

        expect(entry.id, equals(dayKey));
        expect(entry.note, isNull);
        expect(entry.createdAt, equals(earlier));
        expect(entry.updatedAt, equals(now));
        expect(entry.deletedAt, equals(now));
        expect(values, isEmpty);
      });

      test('does nothing when the day has no entry', () async {
        await repository.deleteEntry(day);

        verifyNever(() => database.saveEntry(any(), any()));
      });

      test('throws DeleteEntryFailure when the database fails', () async {
        when(() => database.fetchEntryByDate(any())).thenThrow(Exception('x'));

        await expectLater(
          repository.deleteEntry(day),
          throwsA(isA<DeleteEntryFailure>()),
        );
      });
    });
  });
}
