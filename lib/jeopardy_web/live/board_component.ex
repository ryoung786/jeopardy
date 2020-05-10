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
                <%= if @view == "trebek" do %>
                  <%= if should_display_clue(clue) do %>
                    <div class="clue" style="background:blue; color:gold; height:100px; display:grid; place-items:center;"
                    phx-click="click_clue" phx-value-clue_id=<%= clue.id %>>
                      $<%= clue.value %>
                    </div>
                  <% else %>
                    <div class="clue" style="background:blue; color:gold; height:100px; display:grid; place-items:center;">
                    </div>
                  <% end %>
                <% else %>
                  <div class="clue">
                    <%= if should_display_clue(clue) do %>
                        $<%= clue.value %>
                    <% end %>
                  </div>
              <% end %>
            <% end %>
        </div>
    <% end %>
    </div>
    """
  end
end
