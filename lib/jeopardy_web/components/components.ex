defmodule JeopardyWeb.Components do
  @moduledoc false
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  slot :inner_block, required: true
  slot :timer
  attr :contestants, :map, required: true
  attr :buzzer, :string, default: nil

  def tv(assigns) do
    ~H"""
    <div class="h-screen grid grid-rows-[1fr_25px_auto]" style="background: #221e21;">
      <div class="relative"><%= render_slot(@inner_block) %></div>
      <div class="grid items-center h-full px-2">
        <%= render_slot(@timer) %>
      </div>
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
  attr :daily_double_background?, :boolean, default: false

  def clue(assigns) do
    ~H"""
    <div
      class="bg-blue-800 h-full text-neutral-100 grid p-12 gap-2 grid-rows-[auto_1fr] text-shadow"
      style={
        @daily_double_background? &&
          "background: radial-gradient(circle, rgba(236,182,144,1) 12%, rgba(220,128,129,1) 24%, rgba(171,83,131,1) 40%, rgba(145,77,167,1) 58%, rgba(1,11,121,1) 100%);"
      }
    >
      <h3 class="text-xl font-sans"><%= @category %></h3>
      <h1
        class={[
          "grid text-4xl text-center place-self-center max-w-4xl leading-snug",
          !@daily_double_background? && "font-serif",
          @daily_double_background? && "font-sans font-bold text-7xl"
        ]}
        style={@daily_double_background? && "animation: daily-double 1s;"}
      >
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
      <h1 class="grid text-2xl leading-snug font-serif text-center place-self-center max-w-4xl">
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
      style="border: 5px solid #5f3929; border-bottom: none;"
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
        <div class="category bg-blue-800 p-2 md:p-4 grid place-content-center text-xs md:text-base overflow-hidden">
          <span class={[
            "transition-all",
            @category_reveal_index < i && "invisible opacity-0 translate-y-0.5"
          ]}>
            <%= category %>
          </span>
        </div>
        <div
          :for={clue <- @clues[category]}
          class="bg-blue-800 p-2 grid place-content-center font-bold font-sans text-2xl md:text-3xl lg:text-4xl"
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
  attr :full_width?, :boolean, default: false

  def instructions(assigns) do
    ~H"""
    <div class={[
      "bg-sky-100 grid p-4 h-full w-full items-center",
      !@full_width? && "justify-center"
    ]}>
      <div>
        <%= render_slot(@additional) %>
        <p class="shadow-lg p-4 bg-white rounded-lg text-center">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
    </div>
    """
  end

  @doc """
  Renders a timer in the shape of a filled circle.

  It is animated such that the circle will slowly disappear, like
  a countdown timer.

  By default, it's set to 30 seconds, but you can set the attributes (in ms)
  to adjust.  `time_remaining` allows the timer to pick up in the middle
  of a countdown, like if the page is refreshed.

  ## Examples

      <.pie_timer />
      <.pie_timer timer={5_000} time-remaining={2_000} />
  """
  attr :timer, :integer, default: 30_000
  attr :time_remaining, :integer, default: 30_000
  attr :color, :string, default: "bg-slate-200"

  def pie_timer(assigns) do
    ~H"""
    <div class="flex h-full w-full drop-shadow-lg">
      <div class="overflow-hidden h-full w-1/2">
        <div
          class={"rounded-l-full h-full w-full origin-right #{@color}"}
          style={"animation: #{@timer}ms linear -#{@timer - @time_remaining}ms forwards pie-timer-left;"}
        >
        </div>
      </div>

      <div class="overflow-hidden h-full w-1/2">
        <div
          class={"rounded-r-full h-full w-full origin-left #{@color}"}
          style={"animation: #{@timer}ms linear -#{@timer - @time_remaining}ms forwards pie-timer-right;"}
        >
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders jeopardy podium lights that tick down discretely each second.

  By default it is a 5 second timer.

  It is animated such that one light will disappear each second.

  `time_remaining` allows the timer to pick up in the middle
  of a countdown, like if the page is refreshed.

  ## Examples

      <.lights_timer />
      <.lights_timer timer_seconds={6} time-remaining={2_000} />
  """
  attr :timer_seconds, :integer, default: 5
  attr :time_remaining, :integer, default: 5_000

  def lights_timer(assigns) do
    ~H"""
    <div
      class="flex justify-center gap-x-2"
      style={[
        "clip-path: inset(0 0%);",
        "animation: #{@timer_seconds}s steps(#{@timer_seconds}) -#{:timer.seconds(@timer_seconds) - @time_remaining}ms forwards lights-timer"
      ]}
    >
      <div :for={_ <- 1..(@timer_seconds * 2 - 1)} class="bg-amber-200 w-full h-1" />
    </div>
    """
  end
end
