defmodule JeopardyWeb.Components.Contestant.IntroducingRoles do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="h-screen">
      <.instructions>
        Waiting for <em><%= @trebek %></em> to confirm.
      </.instructions>
    </div>
    """
  end
end
