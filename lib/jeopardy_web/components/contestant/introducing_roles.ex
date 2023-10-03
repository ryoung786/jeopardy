defmodule JeopardyWeb.Components.Contestant.IntroducingRoles do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <p>Waiting for <em><%= @trebek %></em> to confirm.</p>
    </div>
    """
  end
end
