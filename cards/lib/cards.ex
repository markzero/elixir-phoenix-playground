defmodule Cards do
  @moduledoc """
    Handle deck of cards.
  """

  @doc """
    Creates a deck.
  """
  def create_deck do
    values = ["Ace", "Two", "Three"]
    suits = ["Spades", "Clubs", "Hearts", "Diamond"]

    for suit <- suits, value <- values do
      "#{value} of #{suit}"
    end
  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """


      iex> deck = Cards.create_deck
      iex> Cards.contains(deck, "Bad card")
      false
  """
  def contains(deck, card) do
    Enum.member?(deck, card)
  end

  @doc """
    Divides deck by `hand_size`.

  ## Examples

      iex> deck = Cards.create_deck
      iex> {hand, deck} = Cards.deal(deck, 3)
      iex> hand
      ["Ace of Spades", "Two of Spades", "Three of Spades"]

  """
  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
  end

  def save(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end

  def load(filename) do
    case File.read(filename) do
      { :ok, binary } -> :erlang.binary_to_term(binary)
      { :error, _reason } -> "No such file"
    end
  end

  def create_hand(hand_size) do
    Cards.create_deck
    |> Cards.shuffle
    |> Cards.deal(hand_size)
  end
end
