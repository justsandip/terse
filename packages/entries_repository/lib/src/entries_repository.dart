import 'dart:convert';

import 'package:entries_repository/entries_repository.dart';
import 'package:local_database/local_database.dart';
import 'package:metrics_repository/metrics_repository.dart';

/// {@template entries_repository}
/// Stores what a user logged each day.
///
/// A day has one entry. Its id is the day itself, as `YYYY-MM-DD`, so logging
/// a day again, even after deleting it, updates the same row.
/// {@endtemplate}
class EntriesRepository {
  /// {@macro entries_repository}
  const new({required this._database, this._now = _utcNow});

  final LocalDatabase _database;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  /// Returns the entry for [date], or `null` if the day has none.
  ///
  /// The values of a metric the user has since archived are included, because
  /// they were true on that day.
  ///
  /// Throws a [FetchEntryFailure] if reading or decoding fails.
  Future<Entry?> fetchEntry(DateTime date) async {
    try {
      final row = await _database.fetchEntryByDate(_dayOf(date));
      if (row == null) return null;

      final metrics = {
        for (final metric in await _database.fetchAllMetrics())
          metric.id: metric,
      };
      final values = <String, MetricValue>{};
      for (final valueRow in await _database.fetchEntryValues(row.id)) {
        final metric = metrics[valueRow.metricId]!;
        values[metric.key] = _toValue(metric, valueRow);
      }

      return Entry(
        date: DateTime.parse(row.date),
        values: values,
        note: row.note,
      );
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchEntryFailure(error), stackTrace);
    }
  }

  /// Returns the entries from [from] to [to], both days included, oldest
  /// first.
  ///
  /// A day with no entry is left out, so the list can be shorter than the
  /// range. If [from] is after [to] the list is empty. The values of an
  /// archived metric are included, as in [fetchEntry].
  ///
  /// It reads the whole range in a fixed number of queries, however many days
  /// it holds.
  ///
  /// Throws a [FetchEntryFailure] if reading or decoding fails.
  Future<List<Entry>> fetchEntries({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final fromDay = _dayOf(from);
      final toDay = _dayOf(to);
      final rows = await _database.fetchEntriesBetween(fromDay, toDay);
      if (rows.isEmpty) return const [];

      final metrics = await _metricsById();
      final valuesByEntry = <String, List<EntryValueRow>>{};
      for (final valueRow in await _database.fetchValuesBetween(
        fromDay,
        toDay,
      )) {
        (valuesByEntry[valueRow.entryId] ??= []).add(valueRow);
      }

      return [
        for (final row in rows)
          _toEntry(row, valuesByEntry[row.id] ?? const [], metrics),
      ];
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchEntryFailure(error), stackTrace);
    }
  }

  Future<Map<String, MetricRow>> _metricsById() async {
    return {
      for (final metric in await _database.fetchAllMetrics()) metric.id: metric,
    };
  }

  static Entry _toEntry(
    EntryRow row,
    List<EntryValueRow> valueRows,
    Map<String, MetricRow> metrics,
  ) {
    final values = <String, MetricValue>{};
    for (final valueRow in valueRows) {
      final metric = metrics[valueRow.metricId]!;
      values[metric.key] = _toValue(metric, valueRow);
    }
    return Entry(
      date: DateTime.parse(row.date),
      values: values,
      note: row.note,
    );
  }

  /// Saves [entry] as the whole log of its day.
  ///
  /// Values the day had before and [entry] leaves out are removed. A blank note
  /// is saved as no note.
  ///
  /// Throws an [InvalidEntryFailure] if a value does not fit its metric, or if
  /// the metric is not one the user tracks. Throws a [SaveEntryFailure] if
  /// saving fails.
  Future<void> saveEntry(Entry entry) async {
    try {
      final day = _dayOf(entry.date);
      final metrics = {
        for (final metric in await _database.fetchAllMetrics())
          metric.key: metric,
      };

      final valueRows = <EntryValueRow>[];
      for (final MapEntry(key: metricKey, :value) in entry.values.entries) {
        final metric = metrics[metricKey];
        if (metric == null ||
            metric.archivedAt != null ||
            metric.deletedAt != null) {
          throw InvalidEntryFailure(metricKey, 'is not a metric being tracked');
        }
        valueRows.add(_toRow(day, metric, value));
      }

      final existing = await _database.fetchEntryByDate(
        day,
        includeDeleted: true,
      );
      final now = _now();
      final note = entry.note?.trim();

      await _database.saveEntry(
        EntryRow(
          id: day,
          date: day,
          note: note == null || note.isEmpty ? null : note,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ),
        valueRows,
      );
    } on InvalidEntryFailure {
      rethrow;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(SaveEntryFailure(error), stackTrace);
    }
  }

  /// Deletes the entry for [date], if there is one.
  ///
  /// Its note and values are erased. Only a marker stays, so that a later
  /// sync can pass the deletion on.
  ///
  /// Throws a [DeleteEntryFailure] if deleting fails.
  Future<void> deleteEntry(DateTime date) async {
    try {
      final day = _dayOf(date);
      final existing = await _database.fetchEntryByDate(day);
      if (existing == null) return;

      final now = _now();
      await _database.saveEntry(
        EntryRow(
          id: existing.id,
          date: day,
          createdAt: existing.createdAt,
          updatedAt: now,
          deletedAt: now,
        ),
        const [],
      );
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(DeleteEntryFailure(error), stackTrace);
    }
  }

  static String _dayOf(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static MetricValue _toValue(MetricRow metric, EntryValueRow row) {
    return switch (MetricKind.values.byName(metric.kind)) {
      MetricKind.number || MetricKind.scale => NumberValue(row.numberValue!),
      MetricKind.boolean => BooleanValue(row.numberValue != 0),
      MetricKind.choice => ChoiceValue(row.textValue!),
    };
  }

  static EntryValueRow _toRow(
    String entryId,
    MetricRow metric,
    MetricValue metricValue,
  ) {
    final (double? numberValue, String? textValue) = switch ((
      MetricKind.values.byName(metric.kind),
      metricValue,
    )) {
      (MetricKind.number, NumberValue(:final number)) => (
        _checkedNumber(metric, number),
        null,
      ),
      (MetricKind.scale, NumberValue(:final number)) => (
        _checkedScale(metric, number),
        null,
      ),
      (MetricKind.boolean, BooleanValue(:final value)) => (
        value ? 1.0 : 0.0,
        null,
      ),
      (MetricKind.choice, ChoiceValue(:final option)) => (
        null,
        _checkedOption(metric, option),
      ),
      _ => throw InvalidEntryFailure(
        metric.key,
        'a ${metric.kind} cannot hold a ${metricValue.runtimeType}',
      ),
    };

    return EntryValueRow(
      entryId: entryId,
      metricId: metric.id,
      numberValue: numberValue,
      textValue: textValue,
    );
  }

  static double _checkedNumber(MetricRow metric, double number) {
    if (!number.isFinite) {
      throw InvalidEntryFailure(metric.key, 'must be a finite number');
    }
    final min = metric.minValue;
    if (min != null && number < min) {
      throw InvalidEntryFailure(metric.key, '$number is below $min');
    }
    final max = metric.maxValue;
    if (max != null && number > max) {
      throw InvalidEntryFailure(metric.key, '$number is above $max');
    }
    return number;
  }

  static double _checkedScale(MetricRow metric, double number) {
    final checked = _checkedNumber(metric, number);
    if (checked != checked.roundToDouble()) {
      throw InvalidEntryFailure(metric.key, '$number is not a whole number');
    }
    return checked;
  }

  static String _checkedOption(MetricRow metric, String option) {
    final choices = metric.choices;
    final options = choices == null
        ? const <String>[]
        : (jsonDecode(choices) as List<Object?>).cast<String>();
    if (!options.contains(option)) {
      throw InvalidEntryFailure(metric.key, '"$option" is not an option');
    }
    return option;
  }
}
