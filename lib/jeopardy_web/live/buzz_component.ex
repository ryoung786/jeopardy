defmodule JeopardyWeb.BuzzComponent do
  use JeopardyWeb, :live_component
  require Logger

  def render(assigns) do
    ~L"""
    <div class="game buzz">
      <%= if @can_buzz do %>
        <%= submit "Buzz", "phx-click": "buzz" %>
      <% else %>
        <%= submit "Buzz", ["phx-click": "buzz", disabled: true] %>
      <% end %>
    </div>
    """
  end
end
