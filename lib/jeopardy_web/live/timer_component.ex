defmodule JeopardyWeb.TimerComponent do
  use JeopardyWeb, :live_component
  require Logger

  def render(assigns) do
    ~L"""
    <div class="timer">
      <div class="first <%= if @time_left >= 3, do: "on" %>"></div>
      <div class="<%= if @time_left >= 2, do: "on" %>"></div>
      <div class="<%= if @time_left >= 1, do: "on" %>"></div>
      <div class="<%= if @time_left >= 2, do: "on" %>"></div>
      <div class="<%= if @time_left >= 3, do: "on" %>"></div>
    </div>
    """
  end
end
