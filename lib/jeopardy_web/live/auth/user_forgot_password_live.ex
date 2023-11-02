defmodule JeopardyWeb.UserForgotPasswordLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  alias Jeopardy.Accounts

  def render(assigns) do
    ~H"""
    <.curved>
      <h1 class="text-shadow text-4xl">Forgot your password?</h1>
    </.curved>
    <div class="mx-auto max-w-sm pt-8">
      <.header class="text-center">
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full btn-primary">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link class="hover:underline" href={~p"/users/register"}>Register</.link>
        | <.link class="hover:underline" href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
