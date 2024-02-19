defmodule JeopardyWeb.SoloLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  alias Jeopardy.JArchive.RecordedGame.Category.Clue

  @refill_limit 8
  @num_to_fetch 10

  on_mount {JeopardyWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    if connected?(socket), do: Task.async(&fetch_cards!/0)
    {:ok, assign(socket, stats: %{}, deck: [], card: nil, viewing_answer?: false)}
  end

  # [category_name, clue1, clue2, clue3, category_name, clue1, clue2, ...]
  defp fetch_cards!(deck \\ [])
  defp fetch_cards!(deck) when length(deck) >= @num_to_fetch, do: deck

  defp fetch_cards!(deck) do
    {:ok, game_id} = Jeopardy.JArchive.choose_game()

    {:ok, game} = Jeopardy.JArchive.load_game(game_id)

    round = if 0 == Enum.random(0..1), do: game.jeopardy, else: game.double_jeopardy
    category = round |> Enum.shuffle() |> List.first()
    clues = Enum.filter(category.clues, & &1.clue)
    cards = if Enum.empty?(clues), do: [], else: [category.category | clues]

    fetch_cards!(deck ++ cards)
  end

  def handle_event("skip_category", _, socket) do
    if is_binary(socket.assigns.card) do
      [card | deck] = Enum.drop_while(socket.assigns.deck, &match?(%Clue{}, &1))
      keep_deck_from_running_out(deck)
      {:noreply, assign(socket, deck: deck, card: card)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("accept_category", _, socket) do
    if is_binary(socket.assigns.card) do
      [card | deck] = socket.assigns.deck
      keep_deck_from_running_out(deck)
      {:noreply, assign(socket, deck: deck, card: card)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("view_answer", _, socket) when not socket.assigns.viewing_answer? do
    {:noreply, assign(socket, viewing_answer?: true)}
  end

  def handle_event("correct", _, socket) when socket.assigns.viewing_answer? do
    case socket.assigns.card do
      %Clue{} ->
        [card | deck] = socket.assigns.deck
        keep_deck_from_running_out(deck)
        {:noreply, assign(socket, deck: deck, card: card, viewing_answer?: false)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("incorrect", _, socket) when socket.assigns.viewing_answer? do
    case socket.assigns.card do
      %Clue{} ->
        [card | deck] = socket.assigns.deck
        keep_deck_from_running_out(deck)
        {:noreply, assign(socket, deck: deck, card: card, viewing_answer?: false)}

      _ ->
        {:noreply, socket}
    end
  end

  # Our fetch_cards! task result from mount
  def handle_info({_ref, cards}, socket) do
    if socket.assigns.card do
      {:noreply, assign(socket, deck: socket.assigns.deck ++ cards)}
    else
      [card | deck] = socket.assigns.deck ++ cards
      {:noreply, assign(socket, deck: deck, card: card)}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp keep_deck_from_running_out(deck) when length(deck) > @refill_limit, do: :ok
  defp keep_deck_from_running_out(_), do: Task.async(&fetch_cards!/0)
end
