defmodule JeopardyWeb.Components.Trebek.TrebekAdminPanel do
  @moduledoc false
  use JeopardyWeb, :live_component

  alias Jeopardy.FSM.Messages.ScoreUpdated
  alias Jeopardy.GameServer

  def handle_event("remove-contestant", %{"player_name" => name}, socket) do
    game = socket.assigns.game
    game = update_in(game.contestants, &Map.delete(&1, name))
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("edit-score", %{"player_name" => name, "score" => score}, socket) do
    with {score, _} <- Integer.parse(score),
         do: GameServer.admin_action(socket.assigns.game.code, :set_score, {name, score})

    {:noreply, socket}
  end

  def update(%{score_update: %ScoreUpdated{} = msg}, socket) do
    game = socket.assigns.game
    game = put_in(game.contestants[msg.contestant_name].score, msg.to)
    {:ok, assign(socket, game: game)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  ################################################################################
  ## JS Helpers

  def hide_panel(js \\ %JS{}) do
    JS.hide(js,
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-in", "translate-x-0", "translate-x-full"}
    )
  end

  def show_panel(js \\ %JS{}) do
    JS.show(js,
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-out", "translate-x-full", "translate-x-0"}
    )
  end

  def show_confirm_remove(js \\ %JS{}, name) do
    JS.show(js,
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .confirm-remove",
      transition: {"transition-all ease-out", "translate-x-full", "translate-x-0"},
      display: "flex"
    )
  end

  def cancel_remove(js \\ %JS{}, name) do
    JS.hide(js,
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
    |> JS.transition(
      {"transition-all ease-in", "opacity-100", "opacity-0"},
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] > .row"
    )
    |> JS.show(
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .edit-score",
      transition: {"transition-all ease-out", "opacity-0", "opacity-100"},
      display: "flex"
    )
    |> JS.focus(to: "#trebek-admin-panel [data-contestant-name='#{name}'] .score-input")
  end

  def hide_edit_score(js \\ %JS{}, name) do
    js
    |> JS.transition(
      {"transition-all ease-out", "opacity-0", "opacity-100"},
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] > .row"
    )
    |> JS.hide(
      to: "#trebek-admin-panel [data-contestant-name='#{name}'] .edit-score",
      transition: {"transition-all ease-in", "opacity-100", "opacity-0"}
    )
  end
end
