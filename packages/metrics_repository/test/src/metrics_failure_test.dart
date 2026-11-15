import 'package:metrics_repository/metrics_repository.dart';
import 'package:test/test.dart';

void main() {
  group(MetricsFailure, () {
    test('toString includes the type and the error', () {
      const failure = FetchMetricsFailure('boom');
      expect(failure.toString(), equals('FetchMetricsFailure: boom'));
    });
  });
}
