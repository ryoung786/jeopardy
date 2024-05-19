defmodule JeopardyWeb.Components.Contestant.AwaitingBuzz do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div id="awaiting-buzz" class="live-component h-[100dvh]" phx-hook="BuzzTimestamp">
      <.button
        :if={@name not in @game.clue.incorrect_contestants}
        class="btn-primary rounded-none w-full h-full"
        phx-click={JS.dispatch("jeopardy:buzz")}
        phx-target={@myself}
      >
        Buzz
      </.button>
      <.instructions :if={@name in @game.clue.incorrect_contestants}>
        You've already guessed incorrectly.<br /> Other contestants now have a chance to buzz in.
      </.instructions>
    </div>
    """
  end

  def handle_event("buzz", %{"timestamp" => timestamp}, socket) do
    case GameServer.action(socket.assigns.code, :buzz, {socket.assigns.name, timestamp}) do
      {:ok, _game} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end
end
