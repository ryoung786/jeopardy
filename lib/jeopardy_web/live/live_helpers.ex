defmodule JeopardyWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `JeopardyWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, JeopardyWeb.GameLive.FormComponent,
        id: @game.id || :new,
        action: @live_action,
        game: @game,
        return_to: Routes.game_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, JeopardyWeb.ModalComponent, modal_opts)
  end

  defmacro capture(do: expression) do
    quote do
      unquote(expression)
    end
  end
end
