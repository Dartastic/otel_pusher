// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

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
    span.setStringAttribute('messaging.system', 'pusher');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.setStringAttribute('pusher.app.id', res.appId!);
      }
      if (res.cluster != null) {
        span.setStringAttribute('pusher.cluster', res.cluster!);
      }
      if (res.channel != null) {
        span.setStringAttribute('messaging.destination.name', res.channel!);
      }
      if (res.channelType != null) {
        span.setStringAttribute('pusher.channel.type', res.channelType!);
      }
      if (res.event != null) {
        span.setStringAttribute('pusher.event', res.event!);
      }
      if (res.socketId != null) {
        span.setStringAttribute('messaging.client_id', res.socketId!);
      }
      if (res.recipientCount != null) {
        span.setIntAttribute(
          'messaging.batch.message_count',
          res.recipientCount!,
        );
      }
      if (res.encrypted != null) {
        span.setBoolAttribute('pusher.encrypted', res.encrypted!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('pusher.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'pusher.error',
        );
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
