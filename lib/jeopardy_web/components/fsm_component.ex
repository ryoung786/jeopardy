defmodule JeopardyWeb.FSMComponent do
  alias Jeopardy.Game
  alias Phoenix.LiveView.Socket

  @callback assign_init(socket :: Socket.t(), game :: Game.t()) :: Socket.t()
  @callback handle_game_server_msg(msg :: any(), socket :: Socket.t()) ::
              {:ok, Socket.t()}

  defmacro __using__(_opts) do
    quote do
      use JeopardyWeb, :live_component

      @behaviour JeopardyWeb.FSMComponent

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
         |> assign(code: game.code)
         |> assign(trebek: game.trebek)
         |> assign_init(game)}
      end
    end
  end
end
