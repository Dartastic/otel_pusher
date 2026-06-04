// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_pusher_suppression.dart';

class PusherResult {
  const PusherResult({
    this.appId,
    this.cluster,
    this.channel,
    this.channelType,
    this.event,
    this.socketId,
    this.recipientCount,
    this.encrypted,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? appId;
  final String? cluster;
  final String? channel;
  final String? channelType;
  final String? event;
  final String? socketId;
  final int? recipientCount;
  final bool? encrypted;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class PusherCallResult<T> {
  const PusherCallResult({required this.value, this.result});
  final T value;
  final PusherResult? result;
}

Future<T> tracedPusher<T>({
  required String operation,
  required Future<PusherCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (pusherInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_pusher');
  final span = t.startSpan('pusher $operation', kind: SpanKind.producer);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('messaging.system', 'pusher')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('pusher.app.id', res.appId!)]));
      }
      if (res.cluster != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('pusher.cluster', res.cluster!)]));
      }
      if (res.channel != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('messaging.destination.name', res.channel!)
        ]));
      }
      if (res.channelType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('pusher.channel.type', res.channelType!)]));
      }
      if (res.event != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('pusher.event', res.event!)]));
      }
      if (res.socketId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('messaging.client_id', res.socketId!)]));
      }
      if (res.recipientCount != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeInt(
            'messaging.batch.message_count',
            res.recipientCount!,
          )
        ]));
      }
      if (res.encrypted != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeBool('pusher.encrypted', res.encrypted!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('pusher.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'pusher.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
