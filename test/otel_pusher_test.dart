// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
