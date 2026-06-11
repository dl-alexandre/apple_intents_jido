defmodule AppleIntents.JidoTest do
  use ExUnit.Case, async: true

  alias AppleIntents.{Context, Payload}
  alias AppleIntents.Jido
  alias AppleIntentsJido.Test.FakeOrchestrator

  defmodule PhotoIntent do
    use AppleIntents.Intent, intent: "OrganizePhotos"
    use AppleIntents.Jido, task: "organize_photos"
  end

  defmodule IntentRouter do
    use AppleIntents.Router
    use AppleIntents.Jido, orchestrator: AppleIntentsJido.Test.FakeOrchestrator

    handlers do
      [AppleIntents.JidoTest.PhotoIntent]
    end
  end

  setup do
    Application.put_env(:apple_intents_jido, :orchestrator, FakeOrchestrator)

    on_exit(fn ->
      Application.put_env(:apple_intents_jido, :orchestrator, AppleIntents.Jido.Default)
    end)

    payload = %Payload{
      intent_id: "OrganizePhotos",
      request_id: "req_jido_1",
      parameters: %{"query" => "family"},
      raw: %{}
    }

    context = Context.build(payload, orchestrator: FakeOrchestrator)
    {:ok, payload: payload, context: context}
  end

  test "run_task/3 delegates through orchestration" do
    payload = %Payload{intent_id: "OrganizePhotos", request_id: "r1", parameters: %{}, raw: %{}}
    context = Context.build(payload, orchestrator: FakeOrchestrator)

    assert {:ok, %{"status" => "success", "result" => result}} =
             Jido.run_task("organize_photos", %{"query" => "family"}, context,
               orchestrator: FakeOrchestrator
             )

    assert result["orchestrated"] == true
    assert result["via"] == "jido"
  end

  test "use AppleIntents.Jido defines delegated_task and auto handle", %{context: context} do
    assert PhotoIntent.delegated_task() == "organize_photos"

    assert {:ok, %{"status" => "success", "result" => %{"orchestrated" => true}}} =
             PhotoIntent.handle(%{}, context)
  end

  test "router with use AppleIntents.Jido exposes orchestrator/0" do
    assert IntentRouter.orchestrator() == FakeOrchestrator
    assert IntentRouter.handlers() == [PhotoIntent]
  end
end
