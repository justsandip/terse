import 'package:storage/storage.dart';
import 'package:test/test.dart';

typedef ExceptionFactory = StorageException Function(Object, StackTrace);

void main() {
  final stackTrace = StackTrace.current;
  const error = 'boom';

  final factories = <String, ExceptionFactory>{
    'StorageReadException': StorageReadException.new,
    'StorageWriteException': StorageWriteException.new,
    'StorageDeleteException': StorageDeleteException.new,
    'StorageClearException': StorageClearException.new,
  };

  for (final entry in factories.entries) {
    group(entry.key, () {
      final create = entry.value;

      test('is a StorageException and an Exception', () {
        final exception = create(error, stackTrace);
        expect(exception, isA<StorageException>());
        expect(exception, isA<Exception>());
      });

      test('exposes the error and the stack trace', () {
        final exception = create(error, stackTrace);
        expect(exception.error, equals(error));
        expect(exception.stackTrace, equals(stackTrace));
      });

      test('toString includes the type name and the error', () {
        final exception = create(error, stackTrace);
        expect(exception.toString(), equals('${entry.key}: $error'));
      });
    });
  }
}
