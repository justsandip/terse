// ignore_for_file: prefer_const_constructors

import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terse/capture/capture.dart';

void main() {
  group(CaptureEvent, () {
    test('supports value comparison', () {
      expect(const CaptureStarted(), equals(const CaptureStarted()));
      expect(
        CaptureValueSet('mood', NumberValue(3)),
        equals(CaptureValueSet('mood', NumberValue(3))),
      );
      expect(
        const CaptureValueSet('mood', NumberValue(3)),
        isNot(equals(const CaptureValueSet('mood', NumberValue(4)))),
      );
      expect(
        CaptureValueCleared('mood'),
        equals(const CaptureValueCleared('mood')),
      );
      expect(
        const CaptureHabitsConfirmed(),
        equals(const CaptureHabitsConfirmed()),
      );
      expect(
        const CaptureNoteChanged('hi'),
        equals(const CaptureNoteChanged('hi')),
      );
      expect(const CaptureSubmitted(), equals(const CaptureSubmitted()));
      expect(
        const CaptureEditRequested(),
        equals(const CaptureEditRequested()),
      );
    });

    test('props are correct', () {
      expect(const CaptureStarted().props, equals([]));
      expect(
        CaptureValueSet('mood', NumberValue(3)).props,
        equals(['mood', NumberValue(3)]),
      );
      expect(
        const CaptureValueSet('mood', NumberValue(3)).props,
        isNot(equals(['mood', NumberValue(4)])),
      );
      expect(const CaptureValueCleared('mood').props, equals(['mood']));
      expect(const CaptureHabitsConfirmed().props, equals([]));
      expect(const CaptureNoteChanged('hi').props, equals(['hi']));
      expect(const CaptureSubmitted().props, equals([]));
      expect(const CaptureEditRequested().props, equals([]));
    });
  });
}
