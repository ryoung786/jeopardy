defmodule JeopardyWeb.FSMComponent do
  @moduledoc false
  alias Jeopardy.Game
  alias Phoenix.LiveView.Socket

  @callback assign_init(socket :: Socket.t(), game :: Game.t()) :: Socket.t()
  @callback handle_game_server_msg(msg :: any(), socket :: Socket.t()) ::
              {:ok, Socket.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour JeopardyWeb.FSMComponent

      use JeopardyWeb, :live_component

      def assign_init(socket, _game), do: socket
      def handle_game_server_msg(_, socket), do: {:ok, socket}
      defoverridable JeopardyWeb.FSMComponent

      def update(%{game_server_message: msg}, socket) do
        handle_game_server_msg(msg, socket)
      end

      def update(assigns, socket) do
        {:ok, game} = Jeopardy.GameServer.get_game(assigns.code)

        {:ok,
         socket
         |> assign(name: Map.get(assigns, :name))
         |> assign(game: JeopardyWeb.Game.new(game))
         |> assign(code: game.code)
         |> assign(trebek: game.trebek)
         |> assign_init(game)}
      end

      defp handle_tv_player_removed(player_name, socket) do
        game = socket.assigns.game || %{contestants: []}
        {:ok, assign(socket, game: %{game | contestants: Map.delete(game.contestants, player_name)})}
      end
    end
  end
end
