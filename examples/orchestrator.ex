defmodule Examples.Orchestrator do
  @behaviour AppleIntents.Orchestrator

  alias AppleIntents.Context

  @impl true
  def run("organize_photos", params, %Context{} = context, _opts) do
    {:ok,
     %{
       "organized_count" => 47,
       "user_id" => context.payload.user_id,
       "query" => Map.get(params, "query")
     }}
  end

  def run(task, _params, _context, _opts), do: {:error, {:unknown_task, task}}
end