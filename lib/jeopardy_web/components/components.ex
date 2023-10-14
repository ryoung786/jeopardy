defmodule JeopardyWeb.Components do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  slot :inner_block, required: true
  attr :contestants, :map, required: true

  def tv(assigns) do
    ~H"""
    <div>
      <div class="">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="podiums">
        <.podium :for={{name, %{score: score}} <- @contestants} name={name} score={score} />
      </div>
    </div>
    """
  end

  def podium(assigns) do
    ~H"""
    <div>
      <%= @name %>: <%= @score %>
    </div>
    """
  end

  attr :categories, :list, required: true
  attr :clues, :map, required: true
  attr :category_reveal_index, :integer, default: 99_999_999

  def board(assigns) do
    ~H"""
    <div class="grid grid-cols-6 gap-2 text-center font-serif uppercase">
      <div :for={{category, i} <- Enum.with_index(@categories)}>
        <div class={["category", @category_reveal_index < i && "hidden"]}>
          <%= category %>
        </div>
        <div :for={clue <- @clues[category]}>
          <span :if={not clue.asked?}><%= clue.value %></span>
        </div>
      </div>
    </div>
    """
  end
end
