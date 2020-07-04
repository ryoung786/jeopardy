defmodule JeopardyWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use JeopardyWeb, :controller
      use JeopardyWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: JeopardyWeb

      import Plug.Conn
      import JeopardyWeb.Gettext
      alias JeopardyWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/jeopardy_web/templates",
        namespace: JeopardyWeb,
        pattern: "**/*"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {JeopardyWeb.LayoutView, "live.html"}

      defp game_from_socket(socket), do: Jeopardy.Games.get_by_code(socket.assigns.game.code)

      defp component_from_game(%Jeopardy.Games.Game{} = game) do
        view =
          case String.split(Atom.to_string(__MODULE__), ".") |> List.last() do
            "TvLive" -> "TV"
            "GameLive" -> "Game"
            "TrebekLive" -> "Trebek"
          end

        {a, b} = {Macro.camelize(game.status), Macro.camelize(game.round_status)}
        a = if game.status == "double_jeopardy", do: "Jeopardy", else: a
        String.to_existing_atom("Elixir.JeopardyWeb.Components.#{view}.#{a}.#{b}")
      end

      defp render_assigns(assigns) do
        assigns
        |> Map.put(:id, Atom.to_string(assigns.component))
        |> Map.delete(:flash)
      end

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      alias Jeopardy.GameEngine, as: Engine

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import JeopardyWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import JeopardyWeb.ErrorHelpers
      import JeopardyWeb.Gettext
      alias JeopardyWeb.Router.Helpers, as: Routes

      def tpl_path(assigns), do: "#{assigns.game.status}/#{assigns.game.round_status}.html"

      def should_display_clue(clue),
        do: not is_nil(clue) && not Jeopardy.Games.Clue.asked(clue) && not is_nil(clue.clue_text)

      def via_tuple(id), do: {:via, Registry, {Jeopardy.Registry, id}}

      _ = """
      generate a num 1-9 based on the player name and game id, so we can give them a unique font
      """

      def font_from_name(name, game_id) do
        x =
          :crypto.hash(:sha256, name)
          |> Base.encode16()
          |> Integer.parse(16)
          |> elem(0)
          |> (&(&1 * game_id)).()
          |> rem(9)

        "font_#{x}"
      end

      def score(score) when score < 0 do
        ~s(<span class="negative">-$#{abs(score)}</span>) |> raw
      end

      def score(score) do
        ~s(<span>$#{abs(score)}</span>) |> raw
      end

      def ga_tag() do
        case Mix.env() do
          :prod ->
            ~E"""
              <!-- Global site tag (gtag.js) - Google Analytics -->
              <script async src="https://www.googletagmanager.com/gtag/js?id=UA-171375637-1"></script>
              <script>
                window.dataLayer = window.dataLayer || [];
                function gtag(){dataLayer.push(arguments);}
                gtag('js', new Date());

                gtag('config', 'UA-171375637-1');
              </script>
            """

          _ ->
            ""
        end
      end

      def field_display(model, obj, field_name) do
        val = Map.get(obj, field_name)

        case field_name do
          f when f in ~w(correct_answers incorrect_answers)a ->
            x =
              Enum.map(val || [], fn clue_id ->
                ~s(<a href="/admin/clues/#{clue_id}">#{clue_id}</a>)
              end)
              |> Enum.join(", ")

            "[#{x}]"

          f when f in ~w(correct_players incorrect_players)a ->
            x =
              Enum.map(val || [], fn p_id -> ~s(<a href="/admin/players/#{p_id}">#{p_id}</a>) end)
              |> Enum.join(", ")

            "[#{x}]"

          f when f in ~w(air_date inserted_at updated_at)a ->
            if val == nil, do: "nil", else: Date.to_string(val)

          :id when model == Jeopardy.Games.Game ->
            ~s(<a href="/admin/games/#{val}">#{val}</a>)

          :id when model == Jeopardy.Games.Player ->
            ~s(<a href="/admin/players/#{val}">#{val}</a>)

          :id when model == Jeopardy.Games.Clue ->
            ~s(<a href="/admin/clues/#{val}">#{val}</a>)

          :game_id ->
            ~s(<a href="/admin/games/#{val}">#{val}</a>)

          :player_id ->
            ~s(<a href="/admin/players/#{val}">#{val}</a>)

          :current_clue_id ->
            if val == nil, do: "nil", else: ~s(<a href="/admin/clues/#{val}">#{val}</a>)

          _ ->
            if val == nil, do: "nil", else: inspect(val)
        end
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
