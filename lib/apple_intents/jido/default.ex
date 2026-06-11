defmodule AppleIntents.Jido.Default do
  @moduledoc """
  Default Jido orchestrator — runs `Jido.Exec` when `jido_action` is present
  in the host application.
  """

  @behaviour AppleIntents.Orchestrator

  alias AppleIntents.Context
  alias AppleIntents.Jido.Context, as: JidoContext

  @impl AppleIntents.Orchestrator
  def run(task, params, %Context{} = context, opts) do
    with {:ok, action} <- resolve_task(task),
         :ok <- ensure_executable(action),
         jido_context <- JidoContext.to_jido(context, opts),
         {:ok, result} <- execute(action, params, jido_context, opts) do
      {:ok, normalize_result(result)}
    end
  end

  @doc "Resolve a task reference to a Jido action module."
  @spec resolve_task(module() | String.t()) :: {:ok, module()} | {:error, term()}
  def resolve_task(module) when is_atom(module), do: {:ok, module}

  def resolve_task(task_name) when is_binary(task_name) do
    tasks = Application.get_env(:apple_intents_jido, :tasks, %{})

    case Map.get(tasks, task_name) do
      nil -> {:error, {:unknown_task, task_name}}
      action -> {:ok, action}
    end
  end

  defp ensure_executable(action) do
    if jido_available?() do
      :ok
    else
      {:error, {:jido_not_available, action}}
    end
  end

  defp execute(action, params, jido_context, opts) do
    exec_opts = Keyword.take(opts, [:timeout, :jido, :max_retries, :backoff, :log_level])
    # Jido is an optional dependency; apply/3 avoids a compile-time reference.
    # credo:disable-for-next-line Credo.Check.Refactor.Apply
    apply(Jido.Exec, :run, [action, params, jido_context, exec_opts])
  end

  defp jido_available? do
    Code.ensure_loaded?(Jido.Exec) and function_exported?(Jido.Exec, :run, 4)
  end

  defp normalize_result(result) when is_map(result) do
    Map.new(result, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      pair -> pair
    end)
  end

  defp normalize_result(result), do: %{"value" => result}
end
