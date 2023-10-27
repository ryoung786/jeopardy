defmodule JeopardyWeb.JoinHTML do
  use JeopardyWeb, :html

  embed_templates("join_html/*")

  def index(assigns) do
    ~H"""
    <.curved>
      <h1 class="text-shadow">Join Game</h1>
      <h3 class="text-shadow text-base font-mono"><%= @code %></h3>
    </.curved>
    <main class="pt-16 pb-8 px-4 sm:px-6 lg:px-8 flex flex-col items-center">
      <.form for={@form} class="flex flex-col gap-4 w-full max-w-sm" action="">
        <.input field={@form[:name]} placeholder="Name" required />
        <.button class="btn-primary">Join</.button>
      </.form>
    </main>
    """
  end
end
