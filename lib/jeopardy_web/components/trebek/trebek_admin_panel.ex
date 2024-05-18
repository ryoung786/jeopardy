defmodule JeopardyWeb.Components.Trebek.TrebekAdminPanel do
  @moduledoc false
  use JeopardyWeb, :live_component

  alias Jeopardy.GameServer

  def handle_event("remove-contestant", %{"player_name" => name}, socket) do
    contestants = Enum.reject(socket.assigns.contestants, &match?({^name, _score}, &1))
    {:noreply, assign(socket, contestants: contestants)}
  end

  def handle_event("edit-score", %{"player_name" => name, "score" => score}, socket) do
    with {score, _} <- score |> String.replace(~r/[^\d-]/, "") |> Integer.parse(),
         do: GameServer.admin_action(socket.assigns.code, :set_score, {name, score})

    {:noreply, socket}
  end

  def update(assigns, socket) do
    code = assigns[:code] || socket.assigns[:code]
    {:ok, game} = GameServer.get_game(code)
    contestants = Enum.map(game.contestants, fn {name, c} -> {name, c.score} end)
    {:ok, assign(socket, code: code, contestants: contestants)}
  end

  ################################################################################
  ## JS Helpers

  @fade_in {"transition-opacity ease-out", "opacity-0", "opacity-100"}
  @fade_out {"transition-all transform ease-in", "opacity-100", "opacity-0"}

  def hide_panel(js \\ %JS{}) do
    js
    |> JS.hide(to: "#trebek-admin-panel-bg", transition: @fade_out)
    |> JS.hide(
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-in", "translate-x-0", "translate-x-full"}
    )
  end

  def show_panel(js \\ %JS{}) do
    js
    |> JS.show(to: "#trebek-admin-panel-bg", transition: @fade_in)
    |> JS.show(
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-out", "translate-x-full", "translate-x-0"}
    )
  end

  def show_confirm_remove(js \\ %JS{}, name) do
    js
    |> JS.hide(to: "#trebek-admin-panel .actions", transition: @fade_out)
    |> JS.show(
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .confirm-remove",
      transition: {"transition-all ease-out", "translate-x-full", "translate-x-0"},
      display: "flex"
    )
  end

  def cancel_remove(js \\ %JS{}, name) do
    js
    |> JS.show(to: "#trebek-admin-panel .actions", transition: @fade_in)
    |> JS.hide(
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .confirm-remove",
      transition: {"transition-all ease-out", "translate-x-0", "translate-x-full"}
    )
  end

  def confirm_remove(js \\ %JS{}, name) do
    js
    |> JS.push("remove-contestant", value: %{player_name: name})
    |> JS.hide(
      to: "#trebek-admin-panel [data-contestant-name='#{name}']",
      transition: {"transition-all ease-out", "opacity-100 translate-y-0", "opacity-0 -translate-y-4"}
    )
  end

  def show_edit_score(js \\ %JS{}, name) do
    js
    |> JS.transition(@fade_out, to: "#trebek-admin-panel [data-contestant-name='#{name}'] > .row")
    |> JS.show(
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .edit-score",
      transition: @fade_in,
      display: "flex"
    )
    |> JS.focus(to: "#trebek-admin-panel [data-contestant-name='#{name}'] .score-input")
  end

  def hide_edit_score(js \\ %JS{}, name) do
    js
    |> JS.transition(@fade_in, to: "#trebek-admin-panel [data-contestant-name='#{name}'] > .row")
    |> JS.hide(to: "#trebek-admin-panel [data-contestant-name='#{name}'] .edit-score", transition: @fade_out)
  end
end
