defmodule Jeopardy.Admin do
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Player, Clue}
  import Ecto.{Query}

  def all_games(), do: Game |> order_by(desc: :inserted_at) |> Repo.all()

  def get_player(id), do: Repo.get!(Player |> preload([_], [:game]), id)

  def get_clue(id), do: Repo.get!(Clue |> preload([_], [:game]), id)
end
