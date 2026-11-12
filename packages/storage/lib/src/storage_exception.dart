import 'package:storage/storage.dart';

/// {@template storage_exception}
/// Base class for failures thrown by a [Storage] implementation.
/// {@endtemplate}
abstract class StorageException implements Exception {
  /// {@macro storage_exception}
  const new(this.error, this.stackTrace);

  /// The underlying error.
  final Object error;

  /// The stack trace of the underlying [error].
  final StackTrace stackTrace;

  @override
  String toString() => '$runtimeType: $error';
}

/// {@template storage_read_exception}
/// Thrown when reading a value fails.
/// {@endtemplate}
class StorageReadException extends StorageException {
  /// {@macro storage_read_exception}
  const new(super.error, super.stackTrace);
}

/// {@template storage_write_exception}
/// Thrown when writing a value fails.
/// {@endtemplate}
class StorageWriteException extends StorageException {
  /// {@macro storage_write_exception}
  const new(super.error, super.stackTrace);
}

/// {@template storage_delete_exception}
/// Thrown when deleting a value fails.
/// {@endtemplate}
class StorageDeleteException extends StorageException {
  /// {@macro storage_delete_exception}
  const new(super.error, super.stackTrace);
}

/// {@template storage_clear_exception}
/// Thrown when clearing all values fails.
/// {@endtemplate}
class StorageClearException extends StorageException {
  /// {@macro storage_clear_exception}
  const new(super.error, super.stackTrace);
}
