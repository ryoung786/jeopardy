defmodule JeopardyWeb.GameAssigns do
  @moduledoc """
  Ensures game code is assigned in all LiveViews attaching this hook.
  """
  import Phoenix.Component

  def on_mount(:default, %{"code" => code}, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(code)

    {:cont,
     assign(socket,
       code: code,
       state: game.fsm.state
     )}
  end
end
