defmodule AppleIntents.Jido do
  @moduledoc """
  Jido integration for `apple_intents`.

  Add this package when you want App Intent handlers to delegate to
  `Jido.Exec` actions with dry-run and approval previews.

  ## Intent handler

      defmodule MyApp.PhotoIntent do
        use AppleIntents.Intent, intent: "OrganizePhotos", domain: :photos
        use AppleIntents.Jido, task: "organize_photos"
      end

  ## Router

      defmodule MyApp.IntentRouter do
        use AppleIntents.Router
        use AppleIntents.Jido, orchestrator: MyApp.Orchestrator

        handlers do
          [MyApp.PhotoIntent]
        end
      end
  """

  alias AppleIntents.Context
  alias AppleIntents.Jido.Default
  alias AppleIntents.Orchestration

  @type task_ref :: module() | String.t()

  @doc """
  Run a Jido-backed task through the configured orchestrator.

  Delegates to `AppleIntents.Orchestration.run/4` with Jido defaults.
  """
  @spec run_task(task_ref(), map(), Context.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def run_task(task, params, %Context{} = context, opts \\ []) when is_map(params) do
    opts =
      opts
      |> Keyword.put_new(:orchestrator, orchestrator_module(opts))

    Orchestration.run(task, params, context, opts)
  end

  @doc "Run the configured task for an intent module."
  @spec run_from_intent(module(), map(), Context.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def run_from_intent(handler, params, context, opts \\ []) do
    Orchestration.run_from_handler(
      handler,
      params,
      context,
      Keyword.put_new(opts, :orchestrator, orchestrator_module(opts))
    )
  end

  defmacro __using__(opts) do
    action = Keyword.get(opts, :action)
    task = Keyword.get(opts, :task)
    require_approval = Keyword.get(opts, :require_approval, false)
    orchestrator = Keyword.get(opts, :orchestrator)

    quote bind_quoted: [
            action: action,
            task: task,
            require_approval: require_approval,
            orchestrator: orchestrator
          ] do
      if orchestrator do
        def orchestrator, do: unquote(orchestrator)
      else
        @jido_action action
        @jido_task task
        @jido_require_approval require_approval

        def jido_action, do: @jido_action
        def jido_task, do: @jido_task

        @impl AppleIntents.Intent
        def require_approval?, do: @jido_require_approval

        @impl AppleIntents.Intent
        def delegated_task do
          cond do
            not is_nil(@jido_action) -> @jido_action
            not is_nil(@jido_task) -> @jido_task
            true -> nil
          end
        end

        if not is_nil(action) or not is_nil(task) do
          @impl AppleIntents.Intent
          def handle(params, context) do
            AppleIntents.Jido.run_from_intent(__MODULE__, params, context)
          end

          defoverridable handle: 2
        end
      end
    end
  end

  defp orchestrator_module(opts) do
    opts[:orchestrator] ||
      Application.get_env(:apple_intents_jido, :orchestrator, Default)
  end
end
