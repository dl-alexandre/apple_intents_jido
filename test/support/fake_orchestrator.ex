defmodule AppleIntentsJido.Test.FakeOrchestrator do
  @moduledoc false

  @behaviour AppleIntents.Orchestrator

  alias AppleIntents.Context

  @impl true
  def run(task, params, %Context{} = context, _opts) do
    {:ok,
     %{
       "task" => task_name(task),
       "parameters" => params,
       "request_id" => context.payload.request_id,
       "intent_id" => context.payload.intent_id,
       "orchestrated" => true,
       "via" => "jido"
     }}
  end

  defp task_name(task) when is_atom(task), do: Atom.to_string(task)
  defp task_name(task) when is_binary(task), do: task
end
