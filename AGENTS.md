# Agent guide — Apple Intents fulfillment

Use this when wiring LLM agents against `apple_intents` / `apple_intents_jido`.

## Request flow

1. Apple POSTs a signed JWS body (`signedPayload` envelope or raw compact JWS).
2. `AppleIntents.Fulfillment.verify_and_handle/3` verifies ES256 + `x5c` chain, parses claims.
3. `AppleIntents.Router` dispatches to the handler for `intentId`.
4. Delegated intents route through `AppleIntents.Orchestration` (dry-run / approval / orchestrator).
5. Response JSON is returned to Apple / Siri.

## Response statuses

| Status | Meaning |
|--------|---------|
| `success` | Handler completed; see `result` |
| `error` | Verification or handler failure; see `error.code` |
| `dry_run` | Preview only; orchestrator not invoked |
| `approval_required` | Human gate; see `approval` for callback params |
| `rejected` | Approval callback declined |

Schema helpers: `AppleIntents.Schema.fulfillment_request/0`, `fulfillment_response/0`.

## Safe patterns

- **Dry-run first**: pass `dry_run: true` in opts or context to preview without side effects.
- **Approval gate**: set `require_approval?: true` on delegated intents; resume via `AppleIntents.Fulfillment.approve/3`.
- **Never skip JWS verify** in production paths.
- **Prefer stable entity IDs** (server UUID) in parameters for iOS 27 `SyncableEntity` flows.

## Privacy

```elixir
AppleIntents.privacy_manifest(MyApp.PhotoIntent, categories: [:image_metadata, :user_id])
AppleIntents.privacy_to_json(MyApp.PhotoIntent)
```

## Jido bridge

When `apple_intents_jido` is present, map tasks in config:

```elixir
config :apple_intents_jido,
  tasks: %{"organize_photos" => MyApp.Actions.OrganizePhotos}
```

Orchestrator behaviour: implement the `run/4` callback on `AppleIntents.Orchestrator`.