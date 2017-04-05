defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "Creates deck with 12 cards" do
    deck_length = length(Cards.create_deck)
    assert 12 == deck_length
  end
end
