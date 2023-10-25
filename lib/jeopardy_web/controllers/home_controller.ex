defmodule JeopardyWeb.HomeController do
  use JeopardyWeb, :controller

  import Phoenix.Component, only: [to_form: 1, to_form: 2]

  def home(conn, _params) do
    render(conn, :home, form: to_form(%{}))
  end

  def join(conn, %{"name" => name, "code" => code} = params) do
    code = String.upcase(code)

    case Jeopardy.GameServer.action(code, :add_player, name) do
      {:ok, _game} ->
        conn
        |> put_session(:name, name)
        |> put_session(:code, code)
        |> redirect(to: "/games/#{code}")

      {:error, :game_not_found} ->
        form = to_form(params, errors: [code: {"Game does not exist", []}])
        render(conn, :home, form: form)

      {:error, :invalid_action} ->
        form = to_form(params, errors: [code: {"Game already in progress", []}])
        render(conn, :home, form: form)

      {:error, :name_not_unique} ->
        form = to_form(params, errors: [name: {"Already taken, please use another name", []}])
        render(conn, :home, form: form)

      {:error, :name_is_empty} ->
        form = to_form(params, errors: [name: {"Name cannot be empty", []}])
        render(conn, :home, form: form)
    end
  end

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy)
  end
end
