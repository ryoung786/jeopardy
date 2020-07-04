defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingBoard do
  use JeopardyWeb.Components.Base, :trebek
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.GameState

  @impl true
  def mount(socket), do: {:ok, assign(socket, active_category_num: 0)}

  @impl true
  def update(assigns, socket) do
    game = assigns[:game] || socket.assigns[:game]

    socket =
      socket
      |> assign(assigns)
      |> assign(categories: get_zipped_categories(game))

    {:ok, socket}
  end

  @impl true
  def handle_event("next_category", _params, socket) do
    active_category_num = socket.assigns.active_category_num + 1
    broadcast(active_category_num, socket)
    {:noreply, assign(socket, active_category_num: active_category_num)}
  end

  @impl true
  def handle_event("finished_intro", _params, socket) do
    Engine.event(:next, socket.assigns.game.id)
    {:noreply, socket}
  end

  defp get_zipped_categories(%Jeopardy.Games.Game{} = game) do
    categories =
      case game.status do
        "jeopardy" -> game.jeopardy_round_categories
        _ -> game.double_jeopardy_round_categories
      end

    Enum.zip(1..6, categories)
  end

  defp broadcast(active_category_num, socket) do
    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      "game:#{socket.assigns.game.id}",
      %{
        event: :next_category,
        active_category_num: active_category_num
      }
    )
  end
end
