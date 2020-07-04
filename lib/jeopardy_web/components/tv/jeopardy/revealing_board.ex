defmodule JeopardyWeb.Components.TV.Jeopardy.RevealingBoard do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def mount(socket), do: {:ok, assign(socket, active_category_num: 0)}

  @impl true
  def update(%{event: :next_category, active_category_num: num}, socket),
    do: {:ok, assign(socket, active_category_num: num)}

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}
end
