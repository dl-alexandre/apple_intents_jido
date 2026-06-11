# Changelog

## 0.1.1 — 2026-06-10

### Changed

- Documented the intentional dynamic `apply/3` for the optional Jido dependency
- Added credo and dialyxir as dev/test dependencies; `mix credo --strict` is clean

## v0.1.0 — 2026-06-08

### Added

- `AppleIntents.Jido` — `use` macro and `run_task/3` for Jido-backed handlers
- `AppleIntents.Jido.Default` — `Jido.Exec` orchestrator implementing `AppleIntents.Orchestrator`
- `AppleIntents.Jido.Context` — Jido execution context builder
- `mix apple_intents.gen.jido` — snippet generator