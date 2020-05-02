defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Cache, as: Games

  @impl true
  def mount(_params, %{"name" => name} = session, socket) do
    Logger.info("MOUNT #{inspect(session)}")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "1")

    game = Games.find(1)

    socket = socket
    |> assign(name: name)
    |> assign(game: game)
    |> assign(buzzer: game.buzzer)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Welcome <%= @name %></h1>
    <div phx-click="buzz">
      buzz
    </div>
    <%= if @buzzer != :clear do %>
      <div><%= @buzzer %> buzzed in</div>
      <div phx-click="clear">clear buzzer</div>
    <% end %>
    """
  end

  @impl true
  def handle_event("buzz", _, %{assigns: %{name: name}} = socket) do
    Logger.info("buzz attempt by #{name}")
    Games.buzzer(1, name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _, %{assigns: %{name: name}} = socket) do
    Logger.info("#{name} attempted to clear the buzzer")
    Games.clearBuzzer(1)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:buzz, name}, socket) do
    Logger.info("#{name} buzzed in")
    Logger.info("BROADCAST RECEIVED handle_info #{name}")
    {:noreply, update(socket, :buzzer, fn _ -> name end)}
  end

  @impl true
  def handle_info(:clear, %{assigns: %{name: name}} = socket) do
    Logger.info("#{name} successfully cleared the buzzer")
    {:noreply, update(socket, :buzzer, fn _ -> :clear end)}
  end
end
