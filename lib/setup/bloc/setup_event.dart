part of 'setup_bloc.dart';

sealed class SetupEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// A metric was added to the chosen ones.
final class SetupMetricAdded extends SetupEvent {
  const new(this.metric);
  final MetricDefinition metric;

  @override
  List<Object> get props => [metric];
}

/// A metric was removed from the chosen ones.
final class SetupMetricRemoved extends SetupEvent {
  const new(this.metric);
  final MetricDefinition metric;

  @override
  List<Object> get props => [metric];
}

/// A template replaced the chosen metrics.
final class SetupTemplateSelected extends SetupEvent {
  const new(this.template);
  final SetupTemplate template;

  @override
  List<Object> get props => [template];
}

/// The user finished setup and asked to save the chosen metrics.
final class SetupSubmitted extends SetupEvent {
  const new();
}
