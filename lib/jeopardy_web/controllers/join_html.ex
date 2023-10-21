defmodule JeopardyWeb.JoinHTML do
  use JeopardyWeb, :html

  embed_templates("join_html/*")

  def index(assigns) do
    ~H"""
    <div>
      <h3>Join <%= @code %></h3>
      <.form for={@form} class="flex flex-col gap-4" action="">
        <.input field={@form[:name]} placeholder="Name" required />
        <.button class="btn-primary">Join</.button>
      </.form>
    </div>
    """
  end
end
