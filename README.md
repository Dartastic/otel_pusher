# otel_pusher

Dartastic OpenTelemetry bridge for Pusher Channels (WebSocket-as-a-service).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_pusher/otel_pusher.dart';

await tracedPusher<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return PusherCallResult(value: r, result: PusherResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutPusherInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
