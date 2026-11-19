/// {@template entries_failure}
/// Base class for failures thrown by the entries repository.
/// {@endtemplate}
abstract class EntriesFailure implements Exception {
  /// {@macro entries_failure}
  const new(this.error);

  /// The underlying error.
  final Object error;

  @override
  String toString() => '$runtimeType: $error';
}

/// {@template fetch_entry_failure}
/// Thrown when reading an entry fails.
/// {@endtemplate}
class FetchEntryFailure extends EntriesFailure {
  /// {@macro fetch_entry_failure}
  const new(super.error);
}

/// {@template save_entry_failure}
/// Thrown when saving an entry fails.
/// {@endtemplate}
class SaveEntryFailure extends EntriesFailure {
  /// {@macro save_entry_failure}
  const new(super.error);
}

/// {@template delete_entry_failure}
/// Thrown when deleting an entry fails.
/// {@endtemplate}
class DeleteEntryFailure extends EntriesFailure {
  /// {@macro delete_entry_failure}
  const new(super.error);
}

/// {@template invalid_entry_failure}
/// Thrown when an entry holds a value its metric does not allow.
///
/// Nothing is saved when it is thrown.
/// {@endtemplate}
class InvalidEntryFailure extends EntriesFailure {
  /// {@macro invalid_entry_failure}
  new(this.metricKey, String reason) : super('$metricKey: $reason');

  /// The key of the metric whose value is invalid.
  final String metricKey;
}
