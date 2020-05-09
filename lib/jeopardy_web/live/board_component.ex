defmodule JeopardyWeb.BoardComponent do
  use JeopardyWeb, :live_component
  require Logger

  def render(assigns) do
    ~L"""
    <div class="board">
    <%= for [category: category, clues: clues] <- @board do %>
        <div class="category">
            <div class="header">
                <%= category %>
            </div>
            <%= for clue <- clues do %>
                <div class="clue">
                    <%= if should_display_clue(clue) do %>
                        $<%= clue.value %>
                    <% end %>
                </div>
            <% end %>
        </div>
    <% end %>
    </div>
    """
  end
end
