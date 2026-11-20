import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';

void main() {
  group(CaptureState, () {
    const sleep = MetricCatalog.sleepHours;
    const mood = MetricCatalog.mood;
    const exercise = MetricCatalog.exerciseType;
    const metrics = [sleep, mood, exercise];

    final today = DateTime(2026, 11, 19);
    final morning = DateTime(2026, 11, 19, 8);

    CaptureState ready({
      Map<String, MetricValue> suggestions = const {},
      Set<String> fromYesterday = const {},
      Map<String, MetricValue> confirmed = const {},
      String note = '',
      DateTime? startedAt,
      CaptureStatus status = CaptureStatus.ready,
    }) {
      return CaptureState(
        status: status,
        date: today,
        metrics: metrics,
        suggestions: suggestions,
        suggestedFromYesterday: fromYesterday,
        confirmed: confirmed,
        note: note,
        startedAt: startedAt,
      );
    }

    test('starts loading and empty', () {
      const state = CaptureState();

      expect(state.status, equals(CaptureStatus.loading));
      expect(state.date, isNull);
      expect(state.metrics, isEmpty);
      expect(state.note, isEmpty);
      expect(state.canSave, isFalse);
    });

    test('is editable when ready or after a failed save', () {
      expect(ready().isEditable, isTrue);
      expect(ready(status: CaptureStatus.saveFailure).isEditable, isTrue);
      expect(ready(status: CaptureStatus.saving).isEditable, isFalse);
      expect(ready(status: CaptureStatus.saved).isEditable, isFalse);
      expect(ready(status: CaptureStatus.loadFailure).isEditable, isFalse);
      expect(const CaptureState().isEditable, isFalse);
    });

    test('can save once a value or a note exists', () {
      expect(ready().canSave, isFalse);
      expect(ready(note: '   ').canSave, isFalse);
      expect(ready(note: 'ok').canSave, isTrue);
      expect(ready(confirmed: const {'mood': NumberValue(3)}).canSave, isTrue);
      expect(
        ready(
          confirmed: const {'mood': NumberValue(3)},
          status: CaptureStatus.saving,
        ).canSave,
        isFalse,
      );
    });

    test('habitsToConfirm skips scales and what is already set', () {
      final state = ready(
        suggestions: const {
          'sleep_hours': NumberValue(7),
          'mood': NumberValue(4),
          'exercise_type': ChoiceValue('walk'),
        },
        confirmed: const {'exercise_type': ChoiceValue('gym')},
      );

      expect(state.habitsToConfirm, equals(['sleep_hours']));
    });

    test('copyWith changes only what it is given', () {
      final state = ready(note: 'a', fromYesterday: const {'mood'});

      expect(state.copyWith(), equals(state));
      expect(
        state.copyWith(
          status: CaptureStatus.saved,
          elapsed: const Duration(seconds: 14),
          startedAt: morning,
        ),
        equals(
          CaptureState(
            status: CaptureStatus.saved,
            date: today,
            metrics: metrics,
            suggestedFromYesterday: const {'mood'},
            note: 'a',
            startedAt: morning,
            elapsed: const Duration(seconds: 14),
          ),
        ),
      );
    });
  });
}
