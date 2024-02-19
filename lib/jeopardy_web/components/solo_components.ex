defmodule JeopardyWeb.SoloComponents do
  @moduledoc false
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: JeopardyWeb.Endpoint, router: JeopardyWeb.Router

  # alias Phoenix.LiveView.JS

  embed_templates "solo_components/*"

  slot :inner_block, required: true
  attr :type, :string, required: true
  attr :tap, :string, default: nil
  attr :left, :string, default: nil
  attr :right, :string, default: nil
  def card(assigns)
end
