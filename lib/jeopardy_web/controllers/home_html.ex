defmodule JeopardyWeb.HomeHTML do
  use JeopardyWeb, :html

  embed_templates("home_html/*")

  def home(assigns) do
    ~H"""
    <.curved>
      <h1 class="text-shadow">This is Jeopardy!</h1>
      <h2 class="text-base mt-2 pb-4">
        Play real Jeopardy matches with friends, using your phone as a buzzer!
      </h2>
    </.curved>
    <main class="pt-16 pb-8 px-4 sm:px-6 lg:px-8 flex flex-col items-center">
      <div class="flex flex-col w-full items-center gap-8 max-w-sm">
        <.form for={@form} class="flex flex-col gap-4 w-full" action={~p"/"}>
          <.input field={@form[:name]} placeholder="Name" />
          <.input field={@form[:code]} placeholder="ABCD" uppercase />
          <.button class="btn-primary">Join</.button>
        </.form>
        <div class="w-full flex flex-col gap-4">
          <p class="text-center">Or</p>
          <.form for={%{}} class="flex flex-col" action={~p"/new-game"}>
            <.button class="btn-primary">New Game</.button>
          </.form>
          <p class="text-center">Or</p>
          <.link class="btn btn-primary" href={~p"/solo"}>Practice (beta)</.link>
        </div>
      </div>
    </main>
    """
  end
end
