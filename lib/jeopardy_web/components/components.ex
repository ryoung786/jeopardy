defmodule JeopardyWeb.Components do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  slot :inner_block, required: true
  attr :contestants, :map, required: true
  attr :buzzer, :string, default: nil

  def tv(assigns) do
    ~H"""
    <div class="h-screen">
      <div class="">
        <%= render_slot(@inner_block) %>
      </div>
      <div
        class="podiums h-[200px] absolute bottom-0 flex justify-evenly w-screen"
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
  attr :category, :string

  def clue(assigns) do
    ~H"""
    <div
      class="bg-blue-800 w-full h-[500px] text-neutral-100 grid p-12 gap-2"
      style="text-shadow: 2px 2px 2px #000; grid-template-rows: auto 1fr"
    >
      <h3 class="text-xl font-sans"><%= @category %></h3>
      <h1 class="grid place-content-center text-5xl font-serif text-center place-self-center max-w-[700px]">
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
      class="podium grid gap-2 bg-black text-neutral-100 h-[200px] p-1 w-[120px]"
      style="grid-template-rows: 28% 1fr; text-shadow: 2px 2px 2px #000; border-left: 5px solid #5f3929; border-right: 5px solid #5f3929;"
    >
      <div class="score grid place-content-center text-2xl font-bold bg-blue-800 ">
        $<%= @score %>
      </div>
      <div
        class=""
        style={
          if @lit,
            do:
              "background: #e4e2c0; xbox-shadow: inset -4px -4px 4px 0 hsla(0,0%,100%,.3), 0 0 30px 6px hsla(0,0%,100%,.5);",
            else: "background: #000b6e;"
        }
      >
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
