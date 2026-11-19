import 'package:equatable/equatable.dart';

/// {@template metric_value}
/// A value a user set for one metric on one day.
///
/// Which kind of value fits a metric is decided by the metric's kind: a number
/// or a scale holds a [NumberValue], a boolean a [BooleanValue] and a choice a
/// [ChoiceValue].
/// {@endtemplate}
sealed class MetricValue extends Equatable {
  /// {@macro metric_value}
  const new();
}

/// {@template number_value}
/// The value of a number or a scale.
/// {@endtemplate}
final class NumberValue extends MetricValue {
  /// {@macro number_value}
  const new(this.number);

  /// The value itself.
  final double number;

  @override
  List<Object?> get props => [number];
}

/// {@template boolean_value}
/// The value of a boolean: yes or no.
/// {@endtemplate}
final class BooleanValue extends MetricValue {
  /// {@macro boolean_value}
  const new(this.value);

  /// Whether the answer is yes.
  final bool value;

  @override
  List<Object?> get props => [value];
}

/// {@template choice_value}
/// The value of a choice: the option the user picked.
/// {@endtemplate}
final class ChoiceValue extends MetricValue {
  /// {@macro choice_value}
  const new(this.option);

  /// The picked option.
  final String option;

  @override
  List<Object?> get props => [option];
}
