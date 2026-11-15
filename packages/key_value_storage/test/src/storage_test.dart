import 'package:key_value_storage/key_value_storage.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

// KeyValueStorage is exported and can be implemented
class FakeKeyValueStorage extends Fake implements KeyValueStorage;

void main() {
  test('Storage can be implemented', () {
    expect(FakeKeyValueStorage.new, returnsNormally);
  });
}
