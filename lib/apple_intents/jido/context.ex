defmodule AppleIntents.Jido.Context do
  @moduledoc """
  Converts `AppleIntents.Context` into a Jido-compatible execution context map.
  """

  alias AppleIntents.Context
  alias AppleIntents.Payload

  @spec to_jido(Context.t(), keyword()) :: map()
  def to_jido(%Context{} = context, opts \\ []) do
    %{
      intent_id: context.payload.intent_id,
      intent_name: context.payload.intent_name,
      request_id: context.payload.request_id,
      user_id: context.payload.user_id,
      bundle_id: context.payload.bundle_id,
      dry_run: context.dry_run,
      metadata: Map.merge(context.metadata, intent_metadata(context.payload)),
      apple_intents: %{
        payload: context.payload,
        config: context.config
      },
      source: "apple_intents_jido",
      jido: Keyword.get(opts, :jido),
      orchestrator: orchestrator_name(opts, context)
    }
    |> drop_nil_values()
  end

  defp intent_metadata(%Payload{} = payload) do
    %{
      "parameters" => payload.parameters,
      "raw" => payload.raw,
      "issued_at" => payload.issued_at,
      "expires_at" => payload.expires_at
    }
    |> drop_nil_values()
  end

  defp orchestrator_name(opts, context) do
    orchestrator =
      opts[:orchestrator] || context.metadata[:orchestrator] ||
        Application.get_env(:apple_intents_jido, :orchestrator)

    case orchestrator do
      value when is_atom(value) -> Atom.to_string(value)
      value -> value
    end
  end

  defp drop_nil_values(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_map(value) -> {key, drop_nil_values(value)}
      pair -> pair
    end)
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end
end
