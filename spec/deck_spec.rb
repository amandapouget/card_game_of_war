require 'spec_helper'

describe(Deck) do
  describe('#initialize') do
    it('creates a deck with a cards collection that is 52 cards in length') do # I had a lot of fun with these tests :=)
      my_deck = Deck.new
      expect(my_deck.cards.length).to eq 52
    end
    it('has four cards of every rank') do # I like this test because visually, it's exactly how you'd test this with a real deck
      my_deck = Deck.new
      rank_totals = Hash.new(0)
      my_deck.cards.each do |card|
        card.turn_over
        rank_totals[card.rank] += 1
      end
      rank_totals.values.each do |rank_total|
        expect(rank_total).to eq 4
      end
    end
    it('has thirteen cards of every suit') do
      my_deck = Deck.new
      suit_totals = Hash.new(0)
      my_deck.cards.each do |card|
        card.turn_over
        suit_totals[card.suit] += 1
      end
      suit_totals.values.each do |suit_total|
        expect(suit_total).to eq 13
      end
    end
    it('has no two cards that are identical') do
      my_deck = Deck.new
      expect(my_deck.cards.uniq).to eq(my_deck.cards)
    end
  end

  describe('#shuffle') do
    it('reorders the cards in a different way each time') do
      my_deck = Deck.new
      my_unshuffled_deck = Deck.new
      my_deck.cards.each { |card| card.turn_over }
      my_unshuffled_deck.cards.each { |card| card.turn_over }
      expect(my_deck.cards==my_unshuffled_deck.cards).to be true # In this line, I'm testing if I've turned over the cards... ? Else get a test that always passes!
      my_deck.shuffle
      expect(my_deck.cards==my_unshuffled_deck.cards).to be false
      my_unshuffled_deck.shuffle
      expect(my_deck.cards==my_unshuffled_deck.cards).to be false
    end
  end

  describe('#count_cards') do
    it('returns a count of how many cards are in the deck') do
      my_deck = Deck.new
      expect(my_deck.count_cards).to eq 52
      my_deck.deal_next_card
      expect(my_deck.count_cards).to eq 51
    end
  end

  describe('#deal_next_card') do
    it('returns the top card in the deck') do
      my_deck = Deck.new
      my_card = my_deck.cards[0]
      my_card.turn_over
      expect(my_card == my_deck.deal_next_card).to be true
    end
    it('removes that card from the deck') do
      my_deck = Deck.new
      count = my_deck.count_cards
      my_deck.deal_next_card
      expect(my_deck.count_cards). to eq count - 1
    end
  end

  describe('#empty?') do
    it('returns true if all the cards have been dealt') do
      my_deck = Deck.new
      my_deck.count_cards.times { my_deck.deal_next_card }
      expect(my_deck.empty?).to be true
    end
    it('returns false if it still has cards') do
      my_deck = Deck.new
      expect(my_deck.empty?).to be false
    end
  end

  describe('#add_card') do
    it('adds a card to the bottom of the deck') do
      my_deck = Deck.new
      count = my_deck.count_cards
      my_card = Card.new(rank: "three", suit: "spades")
      my_deck.add_card(my_card)
      my_deck.cards[count].turn_over
      expect(my_deck.cards[count]).to eq my_card
    end
    it('increases the deck count by 1') do
      my_deck = Deck.new
      count = my_deck.count_cards
      my_card = Card.new(rank: "three", suit: "spades")
      my_deck.add_card(my_card)
      expect(my_deck.count_cards).to eq count + 1
    end
  end
end
