require 'spec_helper'

describe(Card) do
  describe("#initialize") do
    it('creates a card with the provided rank and suit') do
      myCard = Card.new(7,"Clubs")
      expect(myCard.rank).to eq 7
      expect(myCard.suit).to eq "Clubs"
    end
  end
end
