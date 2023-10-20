defmodule JeopardyWeb.Components.Contestant.RecappingRound do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="w-screen h-[100dvh]">
      <.instructions>Round complete.</.instructions>
    </div>
    """
  end
end
