# Apple Intents (monorepo)

Server-side [App Intents](https://developer.apple.com/documentation/appintents) fulfillment for Elixir backends.

| Package | Hex | Role |
|---------|-----|------|
| [apple_intents](https://hex.pm/packages/apple_intents) | `{:apple_intents, "~> 0.1.0"}` | Framework-agnostic core — JWS, handlers, delegation, approval |
| **`apple_intents_jido`** (this package) | `{:apple_intents_jido, "~> 0.1.0"}` | Optional Jido bridge — `Jido.Exec` orchestration |

## Quick start (core only)

```elixir
# mix.exs
{:apple_intents, "~> 0.1.0"}
```

```elixir
# router
defmodule MyApp.IntentRouter do
  use AppleIntents.Router

  handlers do
    [MyApp.PhotoIntent]
  end
end

# Phoenix webhook
post "/apple/intents/fulfill", AppleIntents.Plug, init_opts: [router: MyApp.IntentRouter]
```

```elixir
# delegated intent
defmodule MyApp.PhotoIntent do
  use AppleIntents.Intent, intent: "OrganizePhotos"
  use AppleIntents.Delegated, task: "organize_photos", require_approval: true
end
```

See [`docs/GUIDE.md`](docs/GUIDE.md) for the full flow (JWS → dispatch → orchestration → approval).

## Quick start (with Jido)

```elixir
def deps do
  [
    {:apple_intents, "~> 0.1.0"},
    {:apple_intents_jido, "~> 0.1.0"},
    {:jido_action, "~> 2.2"}  # in your host app
  ]
end
```

```elixir
config :apple_intents_jido,
  orchestrator: AppleIntents.Jido.Default,
  tasks: %{"organize_photos" => MyApp.Actions.OrganizePhotos}
```

```elixir
defmodule MyApp.PhotoIntent do
  use AppleIntents.Intent, intent: "OrganizePhotos"
  use AppleIntents.Jido, task: "organize_photos"
end

defmodule MyApp.IntentRouter do
  use AppleIntents.Router
  use AppleIntents.Jido, orchestrator: MyApp.Orchestrator

  handlers do
    [MyApp.PhotoIntent]
  end
end
```

Generate snippets:

```bash
mix apple_intents.gen.jido --router MyApp.IntentRouter --task organize_photos
```

## Repository layout

```
apple_intents/          # core Hex package
apple_intents_jido/     # Jido bridge + monorepo docs (this directory)
```

## Agent tooling

See [`AGENTS.md`](AGENTS.md) for JSON response shapes, dry-run semantics, and safe handler patterns.

## License

MIT — see [LICENSE](LICENSE).