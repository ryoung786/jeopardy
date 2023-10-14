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
    <div
      class="grid grid-cols-6 auto-cols-auto gap-1 text-center font-serif uppercase text-neutral-100"
      style="text-shadow: 2px 2px 2px #000"
    >
      <div :for={{category, i} <- Enum.with_index(@categories)} class="grid grid-rows-6 gap-1">
        <div class={[
          "category bg-blue-800 p-4 grid place-content-center min-h-[95px]",
          @category_reveal_index < i && "hidden"
        ]}>
          <%= category %>
        </div>
        <div
          :for={clue <- @clues[category]}
          class="text-amber-500 bg-blue-800 p-4 grid place-content-center font-bold font-sans text-3xl"
          style="color: #dda95e"
        >
          <span :if={not clue.asked?}>$<%= clue.value %></span>
        </div>
      </div>
    </div>
    """
  end
end
