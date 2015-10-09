require 'spec_helper'

describe(Card) do
  describe("#initialize") do
    it('creates a face down card with the provided rank and suit') do
      my_card = Card.new(rank: "seven", suit: "clubs")
      expect(my_card.face_up?).to eq false
      my_card.turn_over
      expect(my_card.rank).to eq "seven"
      expect(my_card.suit).to eq "clubs"
    end
  end

  describe("#face_up?") do
    it('returns true if the card is face_up') do
      my_card = Card.new(rank: "seven", suit: "clubs")
      my_card.turn_over
      expect(my_card.face_up?).to eq true
    end
    it('returns false if the card is face_down') do
      my_card = Card.new(rank: "seven", suit: "clubs")
      expect(my_card.face_up?).to eq false
    end
  end

  describe("#rank") do
    it('returns the card rank if it is face_up') do
      my_card = Card.new(rank: "ace", suit: "spades")
      my_card.turn_over
      expect(my_card.rank).to eq "ace"
    end
    it('does nothing if the card is not face_up') do
      my_card = Card.new(rank: "jack", suit: "diamonds")
      expect(my_card.rank).to eq nil
    end
  end

  describe("#suit") do
    it('returns the card suit if it is face_up') do
      my_card = Card.new(rank: "king", suit: "hearts")
      my_card.turn_over
      expect(my_card.rank).to eq "king"
    end
    it('does nothing if the card is not face_up') do
      my_card = Card.new(rank: "jack", suit: "diamonds")
      expect(my_card.suit).to eq nil
    end
  end

  describe("#rank_numeric_value") do
    it('returns the numeric value of the rank') do
      my_card = Card.new(rank: "seven", suit: "clubs")
      my_card.turn_over
      expect(my_card.rank_numeric_value).to eq 7
    end
    it('works for face cards') do
      my_card = Card.new(rank: "jack", suit: "clubs")
      my_card.turn_over
      expect(my_card.rank_numeric_value).to eq 11
    end
    it('does nothing if the card is not face_up') do
      my_card = Card.new(rank: "jack", suit: "diamonds")
      expect(my_card.rank_numeric_value).to eq nil
    end
  end

  describe('#turn_over') do
    it('toggles face_up between true or false') do
      my_card = Card.new(rank: "eight", suit: "diamonds")
      my_card.turn_over
      expect(my_card.face_up?).to eq true
      my_card.turn_over
      expect(my_card.face_up?).to eq false
      my_card.turn_over
      expect(my_card.face_up?).to eq true
    end
  end

  describe('#==') do
    it('returns true for any two cards of the same rank and suit') do
      my_card = Card.new(rank: "ten", suit: "diamonds")
      my_card2 = Card.new(rank: "ten", suit: "diamonds")
      my_card.turn_over
      my_card2.turn_over
      expect(my_card==my_card2).to be true
    end
    it('returns false if suit is different') do
      my_card = Card.new(rank: "ten", suit: "hearts")
      my_card2 = Card.new(rank: "ten", suit: "diamonds")
      my_card.turn_over
      my_card2.turn_over
      expect(my_card==my_card2).to be false
    end
    it('returns false if rank is different') do
      my_card = Card.new(rank: "four", suit: "clubs")
      my_card2 = Card.new(rank: "five", suit: "clubs")
      my_card.turn_over
      my_card2.turn_over
      expect(my_card==my_card2).to be false
    end
    it('returns false if both rank and suit are different') do
      my_card = Card.new(rank: "nine", suit: "clubs")
      my_card2 = Card.new(rank: "five", suit: "spades")
      my_card.turn_over
      my_card2.turn_over
      expect(my_card==my_card2).to be false
    end
    it('returns false if either card is not face_up') do
      my_card = Card.new(rank: "queen", suit: "hearts")
      my_card2 = Card.new(rank: "three", suit: "hearts")
      my_card2.turn_over
      expect(my_card==my_card2).to be false
    end
  end
end
