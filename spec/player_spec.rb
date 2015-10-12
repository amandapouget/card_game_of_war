require 'spec_helper'

describe Player do

  describe '#initialize' do
    it 'creates a player object with a readable name and a readable array for holding cards' do
      my_player = Player.new(name: "John")
      expect(my_player.name).to eq "John"
      expect(my_player.cards).to eq []
    end

    it 'defaults to Anonymous if no name is given' do
      my_player = Player.new()
      expect(my_player.name).to eq "Anonymous"
    end
  end

  context 'Player with a full deck' do
    let(:player) do
      deck = Deck.new(type: 'regular')
      deck.shuffle
      player = Player.new(name: "Magic Mark")
      deck.cards.each { |card| player.add_card(card) }
      player
    end

    describe '#play_next_card' do
      it 'returns the players top card' do
        card_expected = player.cards[0]
        card_played = player.play_next_card
        expect(card_played).to eq card_expected
      end

      it 'removes the card from the players cards' do
        count = player.count_cards
        player.play_next_card
        expect(player.count_cards).to eq count - 1
      end
      it 'does nothing if the player is out of cards' do
        player.play_next_card until player.out_of_cards?
        expect(player.play_next_card).to eq nil
      end
    end

    describe '#collect_winnings' do
      it 'collects all the winnings from a particular play and adds the cards to the players cards' do
        cards_played = []
        10.times { cards_played << player.play_next_card }
        cards_in_hand = player.count_cards
        player.collect_winnings(cards_played)
        expect(player.count_cards).to eq cards_in_hand + 10
      end
    end

    describe '#add_card' do
      it 'adds a card to the players cards at the bottom' do
        card = Card.new(rank: "ace", suit: "spades")
        player.add_card(card)
        added_card = player.cards.last
        expect(added_card).to eq card
      end
    end

    describe '#count_cards' do
      it 'returns the number of cards a player has' do
        expect(player.count_cards).to eq 52
        player.play_next_card
        expect(player.count_cards).to eq 51
        51.times { player.play_next_card }
        expect(player.count_cards).to eq 0
      end
    end

    describe '#out_of_cards?' do
      it 'returns false when the player still has cards' do
        expect(player.out_of_cards?).to be false
      end
      it 'returns true when the player has no more cards' do
        player.play_next_card until player.count_cards == 0
        expect(player.out_of_cards?).to be true
      end
    end
  end
end
