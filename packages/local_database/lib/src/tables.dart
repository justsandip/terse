// The table classes are read by the code generator, never run, so there is
// nothing here to cover.
// coverage:ignore-file

import 'package:drift/drift.dart';

/// The metrics a user tracks.
@DataClassName('MetricRow')
class Metrics extends Table {
  /// The unique id of the metric: the key for a built-in metric, a UUID for
  /// any other.
  TextColumn get id => text()();

  /// A stable unique identifier, e.g. `sleep_hours`.
  TextColumn get key => text().unique()();

  /// The kind of value the metric holds, as plain text.
  TextColumn get kind => text()();

  /// The unit of a number, e.g. `hours`.
  TextColumn get unit => text().nullable()();

  /// The lowest allowed value of a number or a scale.
  RealColumn get minValue => real().nullable()();

  /// The highest allowed value of a number or a scale.
  RealColumn get maxValue => real().nullable()();

  /// A JSON list of the options of a choice.
  TextColumn get choices => text().nullable()();

  /// How much a number goes up or down with one tap.
  RealColumn get stepValue => real().nullable()();

  /// The value a number jumps to on its first tap.
  RealColumn get startValue => real().nullable()();

  /// Where the metric sits in the user's list, lowest first.
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// When the user stopped tracking the metric, if they did.
  ///
  /// An archived metric is hidden but kept, so old values stay valid.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// When the metric was created, in UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// When the metric last changed, in UTC. A later sync relies on it.
  DateTimeColumn get updatedAt => dateTime()();

  /// When the metric was deleted, if it was. Rows are marked, not removed,
  /// so that a later sync can pass the deletion on.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The days a user has logged: one entry per calendar day.
@DataClassName('EntryRow')
class Entries extends Table {
  /// The unique id of the entry: its date, as `YYYY-MM-DD`.
  TextColumn get id => text()();

  /// The calendar day the entry is about, as `YYYY-MM-DD` in the user's own
  /// time zone.
  ///
  /// It is text, not a timestamp, so that the day does not move when the
  /// phone changes time zone. No two entries share a day.
  TextColumn get date => text().unique()();

  /// The free text the user wrote for the day, if any.
  TextColumn get note => text().nullable()();

  /// When the entry was created, in UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// When the entry, or any of its values, last changed, in UTC. A later sync
  /// relies on it.
  DateTimeColumn get updatedAt => dateTime()();

  /// When the entry was deleted, if it was. Rows are marked, not removed,
  /// so that a later sync can pass the deletion on.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The values of one entry, one row per metric the user set that day.
///
/// A metric the user left out has no row. That is how "not tracked" differs
/// from zero.
@DataClassName('EntryValueRow')
class EntryValues extends Table {
  /// The entry the value belongs to.
  TextColumn get entryId => text().references(Entries, #id)();

  /// The metric the value is for.
  TextColumn get metricId => text().references(Metrics, #id)();

  /// The value of a number, a scale or a yes-no (0 or 1).
  RealColumn get numberValue => real().nullable()();

  /// The value of a choice: the option the user picked.
  TextColumn get textValue => text().nullable()();

  @override
  Set<Column> get primaryKey => {entryId, metricId};

  @override
  List<String> get customConstraints => [
    'CHECK (number_value IS NOT NULL OR text_value IS NOT NULL)',
  ];
}
