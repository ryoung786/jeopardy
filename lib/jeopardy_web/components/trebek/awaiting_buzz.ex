defmodule JeopardyWeb.Components.Trebek.AwaitingBuzz do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <p>Waiting for contestants to buzz in.</p>
    </div>
    """
  end
end
