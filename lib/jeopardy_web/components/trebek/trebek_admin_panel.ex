defmodule JeopardyWeb.Components.Trebek.TrebekAdminPanel do
  @moduledoc false
  use JeopardyWeb, :live_component

  def hide_panel(js \\ %JS{}) do
    JS.hide(js,
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-in", "translate-x-0", "translate-x-full"}
    )
  end

  def show_panel(js \\ %JS{}) do
    JS.show(js,
      to: "#trebek-admin-panel .panel",
      transition: {"transition-all ease-out", "translate-x-full", "translate-x-0"}
    )
  end
end
