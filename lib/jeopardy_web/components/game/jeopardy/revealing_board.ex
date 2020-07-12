defmodule JeopardyWeb.Components.Game.Jeopardy.RevealingBoard do
  use JeopardyWeb.Components.Base, :game

  @impl true
  def mount(socket), do: {:ok, assign(socket, active_category_num: 0)}

  @impl true
  def update(%{event: :next_category, active_category_num: num}, socket),
    do: {:ok, assign(socket, active_category_num: min(num, 6))}

  @impl true
  def update(assigns, socket) do
    game = assigns[:game] || socket.assigns[:game]

    socket =
      socket
      |> assign(assigns)
      |> assign(categories: get_zipped_categories(game))

    {:ok, socket}
  end

  # TODO: duplicated function. consolidate somewhere
  defp get_zipped_categories(%Jeopardy.Games.Game{} = game) do
    categories =
      case game.status do
        "jeopardy" -> game.jeopardy_round_categories
        _ -> game.double_jeopardy_round_categories
      end

    Enum.zip(1..6, categories)
  end
end
