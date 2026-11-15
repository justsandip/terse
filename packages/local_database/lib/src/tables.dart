// The table classes are read by the code generator, never run, so there is
// nothing here to cover.
// coverage:ignore-file

import 'package:drift/drift.dart';

/// The metrics a user tracks.
@DataClassName('MetricRow')
class Metrics extends Table {
  /// The unique id of the metric, a UUID.
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
