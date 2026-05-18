// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_pusher/otel_pusher.dart';
import 'package:test/test.dart';

void main() {
  group('otel_pusher', () {
    test('suppression toggles in zone', () async {
      expect(pusherInstrumentationSuppressed(), isFalse);
      await runWithoutPusherInstrumentationAsync(() async {
        expect(pusherInstrumentationSuppressed(), isTrue);
      });
      expect(pusherInstrumentationSuppressed(), isFalse);
    });

    test('PusherResult fields default null', () {
      const r = PusherResult();
      expect(r.statusCode, isNull);
    });
  });
}
