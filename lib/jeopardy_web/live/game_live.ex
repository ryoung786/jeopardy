defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Cache, as: Games
  require Jeopardy.Cache

  @impl true
  def mount(_params, %{"name" => name} = session, socket) do
    Logger.info("MOUNT #{inspect(session)}")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "buzz")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "clear")

    game = Games.find(1)

    socket = socket
    |> assign(name: name)
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
  def handle_event("buzz", _, socket) do
    Logger.info("BUZZ CLICKED #{inspect(socket.assigns.name)}")
    Games.buzzer(1, socket.assigns.name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _, socket) do
    Logger.info("CLEAR CLICKED")
    Games.clearBuzzer(1)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:buzz, name}, socket) do
    Logger.info("handle_info #{inspect(socket)}")
    Logger.info("BROADCAST RECEIVED handle_info #{name}")
    {:noreply, update(socket, :buzzer, fn _ -> name end)}
  end

  @impl true
  def handle_info(:clear, socket) do
    Logger.info("BROADCAST RECEIVED handle_info clear")
    {:noreply, update(socket, :buzzer, fn _ -> :clear end)}
  end
end
