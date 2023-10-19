defmodule JeopardyWeb.Components.Contestant.RecappingRound do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="w-screen h-screen">
      <.instructions>Round complete.</.instructions>
    </div>
    """
  end
end
