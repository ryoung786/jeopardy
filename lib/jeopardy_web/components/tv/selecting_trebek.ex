defmodule JeopardyWeb.Components.Tv.SelectingTrebek do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    players = game.players |> Map.keys() |> Enum.sort()
    signatures = Map.new(game.players, fn {name, player} -> {name, player.signature} end)
    assign(socket, players: players, signatures: signatures)
  end

  def handle_event("elect_host", %{"player" => name}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :select_trebek, name) do
      {:ok, _game} -> {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end

  # JS interactions

  defp elect_host(name) do
    "elect_host"
    |> JS.push(value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
  end
end
