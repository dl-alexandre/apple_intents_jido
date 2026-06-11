defmodule AppleIntentsJido do
  @moduledoc """
  Optional Jido bridge for `apple_intents`.

  See `AppleIntents.Jido` for the integration API.
  """

  defdelegate run_task(task, params, context, opts \\ []), to: AppleIntents.Jido
end
