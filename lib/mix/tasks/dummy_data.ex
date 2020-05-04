defmodule Mix.Tasks.DummyData do
  use Mix.Task

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Game, Board, Category, Clue}

  @shortdoc "Sends a greeting to us from Hello Phoenix"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    {_, g} = %Game{} |> Repo.insert()
    Mix.shell.info("created game #{inspect(g)}")
    {_, b} = Ecto.build_assoc(g, :board, %{}) |> Repo.insert()
    Mix.shell.info("created board #{inspect(b)}")
    ["The 1990s", "Silent Letter Words", "Broadway Musicals",
     "Don't Blank on the Menu", "Name the Speaker", "WHAT\"EV\"ER"]
    |> Enum.each(fn category_name ->
      {_, cat} = Ecto.build_assoc(b, :categories, %{name: category_name}) |> Repo.insert()
      Mix.shell.info("created category #{inspect(cat)}")
      Enum.each([200, 400, 600, 800, 1000], fn value ->
        {_, _clue} = Ecto.build_assoc(cat, :clues,
        %{answer_text: "George Washington", clue_text: "First president",
          value: value, type: "standard"}) |> Repo.insert()
        Mix.shell.info("created clue")
      end)
    end)

    Mix.shell.info("done")
  end
end
