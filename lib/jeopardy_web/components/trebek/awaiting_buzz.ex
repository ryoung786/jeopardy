defmodule JeopardyWeb.Components.Trebek.AwaitingBuzz do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-[100dvh]">
      <.trebek_clue category={@game.clue.category}><%= @game.clue.clue %></.trebek_clue>
      <div class="p-4 grid">
        <p class="shadow-lg p-4 bg-white rounded-lg text-center">
          Waiting for contestants to buzz in.
        </p>
      </div>
    </div>
    """
  end
end
