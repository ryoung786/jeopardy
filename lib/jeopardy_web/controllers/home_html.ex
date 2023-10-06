defmodule JeopardyWeb.HomeHTML do
  use JeopardyWeb, :html

  embed_templates("home_html/*")

  def home(assigns) do
    ~H"""
    <div>
      <.form for={@form} class="flex flex-col gap-4" action={~p"/"}>
        <.input field={@form[:name]} placeholder="Name" required />
        <.input field={@form[:code]} placeholder="ABCD" required />
        <.button class="btn-primary">Join</.button>
      </.form>
      <p>Or</p>
      <.link class="btn btn-primary" href={~p"/games"}>New Game</.link>
      <.pie_timer />
    </div>
    """
  end
end
