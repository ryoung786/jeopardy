defmodule JeopardyWeb.JoinHTML do
  use JeopardyWeb, :html

  embed_templates("join_html/*")

  def index(assigns) do
    ~H"""
    <.main flash={@flash}>
      <:curved>
        <h1 class="text-shadow">Join Game</h1>
        <h3 class="text-shadow text-base font-mono"><%= @code %></h3>
      </:curved>
      <div class="flex justify-center">
        <.form for={@form} class="flex flex-col gap-4 w-full max-w-sm" action="">
          <.input field={@form[:name]} placeholder="Name" required />
          <.button class="btn-primary">Join</.button>
        </.form>
      </div>
    </.main>
    """
  end
end
