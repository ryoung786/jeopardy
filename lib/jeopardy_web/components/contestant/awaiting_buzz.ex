defmodule JeopardyWeb.Components.Contestant.AwaitingBuzz do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div>
      <.button
        class="btn-primary rounded-none w-screen h-screen"
        phx-click="buzz"
        phx-target={@myself}
      >
        Buzz
      </.button>
    </div>
    """
  end

  def handle_event("buzz", _params, socket) do
    with {:ok, _game} <- GameServer.action(socket.assigns.code, :buzz, socket.assigns.name) do
      {:noreply, socket}
    else
      {:error, _} -> {:noreply, socket}
    end
  end
end
