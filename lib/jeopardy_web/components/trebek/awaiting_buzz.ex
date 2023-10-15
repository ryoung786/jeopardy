defmodule JeopardyWeb.Components.Trebek.AwaitingBuzz do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue category={@game.clue.category} clue={@game.clue.clue} />
      <div class="p-4 grid">
        <p class="shadow-lg p-4 bg-white rounded-lg text-center">
          Waiting for contestants to buzz in.
        </p>
      </div>
    </div>
    """
  end
end
