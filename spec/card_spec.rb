require 'spec_helper'

describe(Card) do
  describe("#initialize") do
    it('creates a face_up card with the provided rank and suit') do
      myCard = Card.new(rank: "seven", suit: "clubs")
      expect(myCard.rank).to eq "seven"
      expect(myCard.suit).to eq "clubs"
      expect(myCard.face_up).to eq true
    end
  end

  describe("#face_up") do
    it('returns true if the card is face_up') do
      myCard = Card.new(rank: "seven", suit: "clubs")
      expect(myCard.face_up).to eq true
    end
    it('returns false if the card is face_down') do
      myCard = Card.new(rank: "seven", suit: "clubs")
      myCard.turn_over
      expect(myCard.face_up).to eq false
    end
  end

  describe("#rank") do
    it('returns the card rank if it is face_up') do
      myCard = Card.new(rank: "ace", suit: "spades")
      expect(myCard.rank).to eq "ace"
    end
    it('does nothing if the card is not face_up') do
      myCard = Card.new(rank: "jack", suit: "diamonds")
      myCard.turn_over
      expect(myCard.rank).to eq nil
    end
  end

  describe("#suit") do
    it('returns the card suit if it is face_up') do
      myCard = Card.new(rank: "king", suit: "hearts")
      expect(myCard.rank).to eq "king"
    end
    it('does nothing if the card is not face_up') do
      myCard = Card.new(rank: "jack", suit: "diamonds")
      myCard.turn_over
      expect(myCard.suit).to eq nil
    end
  end

  describe("#rank_numeric_value") do
    it('returns the numeric value of the rank') do
      myCard = Card.new(rank: "seven", suit: "clubs")
      expect(myCard.rank_numeric_value).to eq 7
    end
    it('works for face cards') do
      myCard = Card.new(rank: "jack", suit: "clubs")
      expect(myCard.rank_numeric_value).to eq 11
    end
    it('does nothing if the card is not face_up') do
      myCard = Card.new(rank: "jack", suit: "diamonds")
      myCard.turn_over
      expect(myCard.rank_numeric_value).to eq nil
    end
  end

  describe('#turn_over') do
    it('toggles face_up between true or false') do
      myCard = Card.new(rank: "eight", suit: "diamonds")
      expect(myCard.face_up).to eq true
      myCard.turn_over
      expect(myCard.face_up).to eq false
      myCard.turn_over
      expect(myCard.face_up).to eq true
    end
  end

end
