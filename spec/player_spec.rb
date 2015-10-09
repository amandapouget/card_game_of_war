require 'spec_helper'

describe Player do
  deck = Deck.new
  deck.shuffle
  stock_cards = deck.cards
  player = Player.new(name: "Magic Mark")
  stock_cards.each { |card| player.add_card(card) }

  describe '#initialize' do
    it 'creates a player object with a name and an empty array for holding cards' do #add win count?
      my_player = Player.new(name: "John")
      expect(my_player.name).to eq "John"
      expect(my_player.cards).to eq []
    end
  end

  describe '#name' do
    it 'returns the players name' do
      my_player = Player.new(name: "Amanda")
      expect(my_player.name).to eq "Amanda"
    end
  end

  describe '#cards' do
    it 'returns the players cards' do
      my_player = Player.new(name: "Amanda")
      stock_cards.each do |card|
        my_player.add_card(card)
      end
      expect(my_player.cards).to match_array stock_cards
    end
  end

  describe '#play_next_card' do
    it 'returns the players top card face_up' do
      card_expected = player.cards[0]
      card_played = player.play_next_card
      expect(card_played).to eq card_expected
      expect(card_played.face_up?).to eq true
    end

    it 'removes the card from the players cards' do
      count = player.count_cards
      player.play_next_card
      expect(player.count_cards).to eq count - 1
    end
    it 'does nothing if the player is out of cards' do
      my_player = Player.new(name: "Smith")
      my_player.play_next_card
      expect(my_player.out_of_cards?).to be true
    end
  end

  describe '#play_war_cards' do
    it 'returns in an array two cards: one card face-down and the next card-face up' do
      cards_played = player.play_war_cards
      expect(cards_played.length).to eq 2
      expect(cards_played[0].face_up?).to be false
      expect(cards_played[1].face_up?).to be true
    end
    it 'draws the two cards from the top of the players cards and removes them from the players cards' do
      cards_expected = [player.cards[0], player.cards[1]]
      cards_played = player.play_war_cards
      cards_played[1].turn_over
      expect(cards_played).to match_array cards_expected
    end
  end

  describe '#collect_winnings' do
    it 'collects all the winnings from a particular play and adds the cards to the players cards' do
      cards_played = []
      cards_played << player.play_next_card
      cards_played << player.play_next_card
      player.play_war_cards.each { |war_card| cards_played << war_card }
      player.play_war_cards.each { |war_card| cards_played << war_card }
      count = player.count_cards
      player.collect_winnings(cards_played)
      expect(player.count_cards).to eq cards_played.length + count
    end
    it 'turns any face_up cards face-down' do
      cards_played = []
      cards_played << player.play_next_card
      cards_played << player.play_next_card
      player.play_war_cards.each { |war_card| cards_played << war_card }
      player.play_war_cards.each { |war_card| cards_played << war_card }
      player.collect_winnings(cards_played)
      all_cards_face_down = true
      player.cards.each { |card| all_cards_face_down = false if card.face_up? }
      expect(all_cards_face_down).to be true
    end
  end

  describe '#add_card' do
    it 'adds a card to the players cards at the bottom' do
      card = Card.new(rank: "ace", suit: "spades")
      player.add_card(card)
      added_card = player.cards.last
      added_card.turn_over
      expect(added_card).to eq card
    end
    it 'turns the card face_down if it is face_up' do
      card = Card.new(rank: "ace", suit: "spades")
      player.add_card(card)
      added_card = player.cards.last
      expect(added_card.face_up?).to be false
    end
  end

  describe '#count_cards' do
    it 'returns the number of cards a player has' do
      my_player = Player.new(name: "Green Gables")
      expect(my_player.count_cards).to eq 0
      my_player.add_card(Card.new(rank: "two", suit: "hearts"))
      expect(my_player.count_cards).to eq 1
      my_player.add_card(Card.new(rank: "three", suit: "hearts"))
      expect(my_player.count_cards).to eq 2
      my_player.add_card(Card.new(rank: "four", suit: "hearts"))
      expect(my_player.count_cards).to eq 3
    end
  end

  describe '#out_of_cards?' do
    it 'returns false when the player still has cards' do
      my_player = Player.new(name: "Amanda")
      stock_cards.each do |card|
        my_player.add_card(card)
      end
      expect(my_player.out_of_cards?).to be false
    end
    it 'returns true when the player has no more cards' do
      my_player = Player.new(name: "Amanda")
      stock_cards.each do |card|
        my_player.add_card(card)
      end
      my_player.play_next_card until my_player.count_cards==0
      expect(my_player.out_of_cards?).to be true
    end
  end
end
