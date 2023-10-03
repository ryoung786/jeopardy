defmodule JeopardyWeb.Components.Contestant.SelectingTrebek do
  use JeopardyWeb.FSMComponent

  def handle_event("volunteer", _params, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :select_trebek, socket.assigns.name)
    {:noreply, socket}
  end
end
