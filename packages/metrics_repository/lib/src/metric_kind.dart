/// The kind of value a metric holds. It decides how the value is entered,
/// validated and charted.
enum MetricKind {
  /// A quantity with an optional unit, e.g. hours of sleep.
  number,

  /// A whole number on a fixed scale, e.g. mood from 1 to 5.
  scale,

  /// One option out of a fixed list, e.g. the type of exercise.
  choice,

  /// Either true or false, shown to the user as a yes or no.
  boolean,
}
