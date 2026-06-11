defmodule Examples.IntentRouter do
  use AppleIntents.Router
  use AppleIntents.Jido, orchestrator: Examples.Orchestrator

  handlers do
    [Examples.PhotoIntent]
  end
end