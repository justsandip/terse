import 'package:entries_repository/entries_repository.dart';
import 'package:equatable/equatable.dart';

/// {@template entry}
/// What a user logged on one calendar day.
/// {@endtemplate}
class Entry extends Equatable {
  /// {@macro entry}
  const new({required this.date, this.values = const {}, this.note});

  /// The calendar day the entry is about. Only its year, month and day;
  /// the time of day is ignored.
  final DateTime date;

  /// The values the user set, by the key of their metric.
  ///
  /// A metric the user left out has no value. That is different from zero.
  final Map<String, MetricValue> values;

  /// The free text the user wrote for the day, if any.
  final String? note;

  @override
  List<Object?> get props => [date, values, note];
}
