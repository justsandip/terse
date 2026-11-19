import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metrics_repository/metrics_repository.dart';

part 'metric_definition.g.dart';

/// {@template metric_definition}
/// Describes one thing a user tracks.
///
/// Only the fields that fit its [kind] are set: [unit], [min] and [max] for a
/// number, [min] and [max] for a scale, and [choices] for a choice.
/// {@endtemplate}
@JsonSerializable(includeIfNull: false)
class MetricDefinition extends Equatable {
  /// {@macro metric_definition}
  const new({
    required this.key,
    required this.kind,
    this.unit,
    this.min,
    this.max,
    this.step,
    this.start,
    this.choices = const [],
  });

  /// Creates a [MetricDefinition] from the JSON made by [toJson].
  ///
  /// Throws if [json] is malformed.
  factory fromJson(Map<String, dynamic> json) =>
      _$MetricDefinitionFromJson(json);

  /// A stable identifier, e.g. `sleep_hours`. Display labels are derived from
  /// it by the UI and are not stored here.
  final String key;

  /// The kind of value this metric holds.
  final MetricKind kind;

  /// The unit of a number, e.g. `hours`.
  final String? unit;

  /// The lowest allowed value of a number or a scale.
  final double? min;

  /// The highest allowed value of a number or a scale.
  final double? max;

  /// How much a number goes up or down with one tap, e.g. `0.5` for hours of
  /// sleep. A number without one steps by 1.
  final double? step;

  /// The value a number jumps to on its first tap, e.g. `7` for hours of
  /// sleep.
  ///
  /// Until the user taps, the number has no value at all. It is not saved as
  /// zero or as [start].
  final double? start;

  /// The allowed options of a choice.
  @JsonKey(toJson: _choicesToJson)
  final List<String> choices;

  /// Converts this definition to JSON. Unset fields are left out.
  Map<String, Object?> toJson() => _$MetricDefinitionToJson(this);

  @override
  List<Object?> get props => [key, kind, unit, min, max, step, start, choices];

  static List<String>? _choicesToJson(List<String> choices) =>
      choices.isEmpty ? null : choices;
}
