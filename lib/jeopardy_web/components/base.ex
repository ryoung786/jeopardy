defmodule JeopardyWeb.Components.Base do
  def game do
    quote do
      use JeopardyWeb, :live_component
      require Logger

      @impl true
      def render(assigns), do: JeopardyWeb.GameView.render(tpl_path(assigns), assigns)
    end
  end

  def tv do
    quote do
      use JeopardyWeb, :live_component
      require Logger

      @impl true
      def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)
    end
  end

  def trebek do
    quote do
      use JeopardyWeb, :live_component
      require Logger

      @impl true
      def render(assigns), do: JeopardyWeb.TrebekView.render(tpl_path(assigns), assigns)
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
