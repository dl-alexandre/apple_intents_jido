# Apple Intents fulfillment guide

## Packages

- **`apple_intents`** — production webhook library (Phoenix/Plug/Oban/custom).
- **`apple_intents_jido`** — optional `Jido.Exec` orchestrator.

## Core modules

| Module | Purpose |
|--------|---------|
| `AppleIntents` | Facade — `verify_and_handle/3`, `approve/3`, privacy helpers |
| `AppleIntents.Fulfillment` | Main entry point |
| `AppleIntents.JWS` | ES256 verification, `signedPayload` extraction |
| `AppleIntents.Intent` | Handler behaviour + `use` macro |
| `AppleIntents.Delegated` | Zero-boilerplate delegation |
| `AppleIntents.Router` | Intent registry + dispatch |
| `AppleIntents.Orchestration` | Dry-run, approval, orchestrator dispatch |
| `AppleIntents.Plug` | Fulfillment webhook |
| `AppleIntents.ApprovalPlug` | Human approval callback |

## Delegation without Jido

```elixir
defmodule MyApp.IntentRouter do
  use AppleIntents.Router

  def orchestrator, do: MyApp.ObanOrchestrator

  handlers do
    [MyApp.PhotoIntent]
  end
end
```

See `apple_intents/examples/oban_orchestrator.ex` for an Oban pattern.

## Approval webhook

```elixir
post "/apple/intents/approve", AppleIntents.ApprovalPlug,
  init_opts: [router: MyApp.IntentRouter]
```

Callback params: `intent_id`, `request_id`, `approved`, `parameters`.

## Publishing

Both packages ship at **v0.1.0** from this monorepo:

1. `cd apple_intents && mix hex.publish`
2. `cd apple_intents_jido && mix hex.publish` (depends on `apple_intents ~> 0.1.0`)