defmodule JeopardyWeb.JoinController do
  use JeopardyWeb, :controller

  import Phoenix.Component, only: [to_form: 1, to_form: 2]

  def index(conn, params) do
    render(conn, :index, form: to_form(%{}), code: params["code"])
  end

  def join(conn, %{"name" => name, "code" => code} = params) do
    code = String.upcase(code)

    case Jeopardy.GameServer.action(code, :add_player, name) do
      {:ok, _game} ->
        conn
        |> put_session(:name, name)
        |> put_session(:code, code)
        |> redirect(to: ~p"/games/#{code}")

      {:error, :game_not_found} ->
        form = to_form(params, errors: [code: {"Game does not exist", []}])
        render(conn, :index, form: form, code: code)

      {:error, :invalid_action} ->
        form = to_form(params, errors: [code: {"Game already in progress", []}])
        render(conn, :index, form: form, code: code)

      {:error, :name_not_unique} ->
        form = to_form(params, errors: [name: {"Already taken, please use another name", []}])
        render(conn, :index, form: form, code: code)
    end
  end
end
