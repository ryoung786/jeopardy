defmodule JeopardyWeb.Components do
  @moduledoc false
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: JeopardyWeb.Endpoint, router: JeopardyWeb.Router

  alias Phoenix.LiveView.JS

  embed_templates "functional_components/*"

  slot :inner_block, required: true
  slot :timer
  attr :contestants, :map, required: true
  attr :buzzer, :string, default: nil
  def tv(assigns)

  slot :inner_block, required: true
  attr :category, :string, default: nil
  attr :daily_double_background?, :boolean, default: false
  def clue(assigns)

  slot :inner_block, required: true
  attr :category, :string, default: nil
  def trebek_clue(assigns)

  attr :name, :string, required: true
  attr :score, :integer, default: 0
  attr :lit, :boolean, default: false
  attr :signature, :string, default: nil
  def podium(assigns)

  attr :categories, :list, required: true
  attr :clues, :map, required: true
  attr :category_reveal_index, :integer, default: 99_999_999
  def board(assigns)

  slot :inner_block, required: true
  slot :additional
  attr :full_width?, :boolean, default: false
  def instructions(assigns)

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
  def pie_timer(assigns)

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
  def lights_timer(assigns)

  slot :inner_block, required: true
  attr :show, :boolean, default: false
  def reveal_text(assigns)

  attr :content, :any
  attr :width_class, :string, default: "w-full"
  def qr_code(assigns)

  attr :user, :any, required: true
  def account_icon(assigns)

  slot :inner_block, default: nil
  attr :text, :string
  def curved(assigns)

  slot :inner_block
  slot :curved, default: nil
  attr :flash, :any, required: true
  def main(assigns)
end
