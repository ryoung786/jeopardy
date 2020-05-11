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
                <%= if should_display_clue(clue) do %>
                  <div class="clue <%= if @view == "trebek", do: "clickable" %>" <%= if @view == "trebek" do %>phx-click="click_clue" phx-value-clue_id=<%= clue.id %><% end %> >
                    $<%= clue.value %>
                  </div>
                <% else %>
                  <div class="clue"></div>
                <% end %>
            <% end %>
        </div>
    <% end %>
    </div>
    """
  end
end
