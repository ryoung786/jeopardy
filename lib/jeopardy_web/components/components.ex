defmodule JeopardyWeb.Components do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  slot :inner_block, required: true
  slot :timer
  attr :contestants, :map, required: true
  attr :buzzer, :string, default: nil

  def tv(assigns) do
    ~H"""
    <div class="h-screen grid grid-rows-[1fr_30px_auto]">
      <div class="">
        <%= render_slot(@inner_block) %>
      </div>
      <div><%= render_slot(@timer) %></div>
      <div
        class="podiums flex justify-evenly w-screen"
        style="background: linear-gradient(to bottom, #5f3929, #5f3929 7%, #dab777 7%, #dab777 10%, #5f3929 10%, #5f3929 17%, #dab777 17%, #dab777 20%, #5f3929 20%, #5f3929 30%, #221e21 30%, #221e21 95%, #5f3929 95%, #5f3929)"
      >
        <.podium
          :for={{name, %{score: score}} <- @contestants}
          name={name}
          score={score}
          lit={name == @buzzer}
        />
      </div>
    </div>
    """
  end

  attr :clue, :string, required: true
  attr :category, :string, default: nil

  def clue(assigns) do
    ~H"""
    <div class="bg-blue-800 h-full text-neutral-100 grid p-12 gap-2 grid-rows-[auto_1fr] text-shadow">
      <h3 class="text-xl font-sans"><%= @category %></h3>
      <h1 class="grid place-content-center text-5xl font-serif text-center place-self-center max-w-[700px]">
        <%= @clue %>
      </h1>
    </div>
    """
  end

  attr :clue, :string, required: true
  attr :category, :string, default: nil

  def trebek_clue(assigns) do
    ~H"""
    <div class="bg-blue-800 h-full text-neutral-100 grid p-4 gap-2 grid-rows-[auto_1fr] text-shadow">
      <h3 class="font-sans"><%= @category %></h3>
      <h1 class="grid place-content-center text-2xl font-serif text-center place-self-center max-w-[700px]">
        <%= @clue %>
      </h1>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :score, :integer, default: 0
  attr :lit, :boolean, default: false

  def podium(assigns) do
    ~H"""
    <div
      class="podium grid gap-2 bg-black text-neutral-100 h-[200px] p-1 w-[120px] text-shadow grid-rows-[28%_1fr]"
      style="border-left: 5px solid #5f3929; border-right: 5px solid #5f3929;"
    >
      <div class="score grid place-content-center text-2xl font-bold bg-blue-800 ">
        $<%= @score %>
      </div>
      <div class={if @lit, do: "lit", else: "unlit"}>
        <div class="name mt-[20px] bg-blue-800 grid place-content-center h-[70px]">Ryan</div>
      </div>
    </div>
    """
  end

  attr :categories, :list, required: true
  attr :clues, :map, required: true
  attr :category_reveal_index, :integer, default: 99_999_999

  def board(assigns) do
    ~H"""
    <div class="h-full grid grid-cols-6 auto-cols-auto gap-1 text-center font-serif uppercase text-neutral-100 text-shadow">
      <div
        :for={{category, i} <- Enum.with_index(@categories)}
        class="grid gap-1 overflow-hidden"
        style="grid-template-rows: 16% repeat(5, 1fr)"
      >
        <div class={[
          "category bg-blue-800 p-4 grid place-content-center text-xs md:text-base overflow-hidden",
          @category_reveal_index < i && "hidden"
        ]}>
          <%= category %>
        </div>
        <div
          :for={clue <- @clues[category]}
          class="bg-blue-800 p-2 grid place-content-center font-bold font-sans sm:text-lg md:text-xl lg:text-3xl"
          style="color: #dda95e"
        >
          <span :if={not clue.asked?}>$<%= clue.value %></span>
        </div>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true
  slot :additional

  def instructions(assigns) do
    ~H"""
    <div class="bg-sky-100 grid place-content-center w-screen h-screen">
      <div>
        <%= render_slot(@additional) %>
        <p class="shadow-lg p-4 bg-white rounded-lg text-center">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
    </div>
    """
  end
end
