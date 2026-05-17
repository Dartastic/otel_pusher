# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedPusher<T>(...)` — wraps a otel_pusher call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutPusherInstrumentation()` / `Async()`.
