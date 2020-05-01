defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Cache, as: Games
  require Jeopardy.Cache

  @impl true
  def mount(_params, %{"name" => name} = session, socket) do
    Logger.info("MOUNT #{inspect(session)}")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "buzz")
    socket = socket
    |> assign(name: name)
    |> assign(buzzer: :clear)

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
    <% end %>
    """
  end

  @impl true
  def handle_event("buzz", _, socket) do
    Logger.info("BUZZ #{inspect(socket.assigns.name)}")
    if socket.assigns.buzzer == :clear do
      Logger.info("buzzer is clear")
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, "buzz", {:buzz, socket.assigns.name})
      Logger.info("broadcasted")
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:buzz, name}, socket) do
    Logger.info("handle_info #{inspect(socket)}")
    Logger.info("handle_info #{name}")
    :ets
    {:noreply, update(socket, :buzzer, fn _ -> name end)}
  end
end
