import 'package:storage/storage.dart';

/// {@template storage}
/// A key-value storage contract.
///
/// Implementations decide where values live, for example on the device, in a
/// secure store, or in a remote database.
/// {@endtemplate}
abstract interface class Storage {
  /// Returns the value stored under [key], or `null` if there is none.
  ///
  /// Throws a [StorageReadException] if the read fails.
  Future<String?> read({required String key});

  /// Stores [value] under [key], replacing any existing value.
  ///
  /// Throws a [StorageWriteException] if the write fails.
  Future<void> write({required String key, required String value});

  /// Removes the value stored under [key], if there is one.
  ///
  /// Throws a [StorageDeleteException] if the delete fails.
  Future<void> delete({required String key});

  /// Removes every stored value.
  ///
  /// Throws a [StorageClearException] if the clear fails.
  Future<void> clear();
}
