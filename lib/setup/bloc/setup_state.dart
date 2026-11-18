part of 'setup_bloc.dart';

/// Where the setup is: being edited, being saved, saved, or failed to save.
enum SetupStatus { editing, saving, success, failure }

/// A ready-made group of metrics.
enum SetupTemplate {
  sleep([
    MetricCatalog.sleepHours,
    MetricCatalog.sleepQuality,
    MetricCatalog.caffeine,
  ]),
  mood([MetricCatalog.mood, MetricCatalog.energy, MetricCatalog.stress]),
  fitness([
    MetricCatalog.exerciseType,
    MetricCatalog.exerciseMinutes,
    MetricCatalog.energy,
    MetricCatalog.sleepHours,
  ]);

  new(this.metrics);

  final List<MetricDefinition> metrics;
}

final class SetupState extends Equatable {
  const new({this.selected = const [], this.status = SetupStatus.editing});

  /// The most metrics a user can track.
  static const maxMetrics = 6;

  /// The chosen metrics, in the order they will appear.
  final List<MetricDefinition> selected;

  final SetupStatus status;

  bool get isFull => selected.length >= maxMetrics;

  bool get canStart => selected.isNotEmpty && status != SetupStatus.saving;

  /// The template whose metrics are exactly the chosen ones, if there is one.
  SetupTemplate? get matchedTemplate {
    for (final template in SetupTemplate.values) {
      if (template.metrics.length == selected.length &&
          selected.toSet().containsAll(template.metrics)) {
        return template;
      }
    }
    return null;
  }

  /// The built-in metrics that are not chosen yet.
  List<MetricDefinition> get available => [
    for (final metric in MetricCatalog.all)
      if (!selected.contains(metric)) metric,
  ];

  @override
  List<Object> get props => [selected, status];
}
