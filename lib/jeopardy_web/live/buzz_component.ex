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
    <!-- <h2>current clue: <%= @current_clue.category %>: $<%= @current_clue.value %></h2> -->
    """
  end
end
