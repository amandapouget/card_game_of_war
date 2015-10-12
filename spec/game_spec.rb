require 'spec_helper'

describe Game do
  context 'game is initialized with two players' do
    let(:player1) { Player.new(name: "Amanda") }
    let(:player2) { Player.new(name: "Vianney") }
    let(:game) { Game.new(player1: player1, player2: player2) }

    describe '#initialize' do
      it 'creates a game with two players and a regular deck full of cards' do
        expect(game.player1).to eq player1
        expect(game.player2).to eq player2
        expect(game.deck.type).to eq 'regular'
      end
    end

    describe '#deal' do
      it 'deals the cards to each player until all the cards are dealt' do
        half_the_deck = game.deck.count_cards / 2
        game.deal
        player1_dist_from_half = player1.count_cards - half_the_deck
        player2_dist_from_half = player2.count_cards - half_the_deck
        expect(player1.count_cards).to be_within(1).of half_the_deck
        expect(player2.count_cards).to be_within(1).of half_the_deck
        expect(game.deck.count_cards).to eq 0
      end
    end
  end

  context 'game started and deck is freshly dealt' do
    let(:player1) { Player.new(name: "Amanda") }
    let(:player2) { Player.new(name: "Vianney") }
    let(:game) { Game.new(player1: player1, player2: player2) }

    before(:each) do
      game.deal
    end

    describe '#play_round' do
      it 'gets a card from each player, compares who won, sends the player his winnings, increments rounds_played and returns round winner' do
        player1.play_next_card until player1.cards[0].rank_value < player2.cards[0].rank_value
        player1_count = player1.count_cards
        player2_count = player2.count_cards
        card_to_win = player1.cards[0]
        expect(game.play_round).to eq player2
        expect(player1.count_cards).to eq player1_count - 1
        expect(player2.count_cards).to eq player2_count + 1
        expect(player2.cards.include?(card_to_win)).to be true
        expect(game.rounds_played).to eq 1
      end
    end
  end

  context 'war' do
    let(:player1) { player1 = Player.new(name: "Amanda") }
    let(:player2) { Player.new(name: "Vianney") }
    let(:game) { Game.new(player1: player1, player2: player2) }
    let(:card_ks) { Card.new(rank:"king", suit: "spades") }
    let(:card_kh) { Card.new(rank:"king", suit: "hearts") }
    let(:card_js) { Card.new(rank: "jack", suit: "spades") }
    let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
    let(:card_9d) { Card.new(rank: "nine", suit: "diamonds") }
    let(:card_4c) { Card.new(rank: "four", suit: "clubs") }

    before do
      player1.add_card(card_ks)
      player2.add_card(card_kh)
    end

    describe '#play_round' do
      it 'in the case of no winner, plays war and successfully finishes the round' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        player1.add_card(card_9d)
        player2.add_card(card_4c)
        expect(game.play_round).to eq player1
        expect(player2.count_cards).to be 0
        expect(player1.cards).to match_array [card_ks, card_kh, card_js, card_ad, card_9d, card_4c]
      end

      it 'in case of one player having no cards to play war, successfully ends the game' do
        player2.add_card(card_ad)
        player2.add_card(card_4c)
        expect(game.play_round).to eq player2
        expect(player1.count_cards).to eq 0
        expect(game.game_over?).to be true
        expect(game.winner).to eq player2
      end

      it 'in case of one player having only one card to play war, successfully ends the game' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        player1.add_card(card_9d)
        expect(game.play_round).to eq player1
        expect(player2.count_cards).to eq 0
        expect(game.game_over?).to be true
        expect(game.winner).to eq player1
      end
    end
  end

  context 'end-game' do
    let(:player1) { Player.new(name: "Amanda") }
    let(:player2) { Player.new(name: "Vianney") }
    let(:card) { Card.new(rank: 'ace', suit: 'spades') }
    let(:card2) { Card.new(rank: 'ten', suit: 'spades') }
    let(:game) { Game.new(player1: player1, player2: player2) }

    describe '#declare_game_winner' do
      it 'returns player1 if player2 is out of cards' do
        player1.add_card(card)
        game.declare_game_winner
        expect(game.winner).to eq player1
      end

      it 'returns player2 if player1 is out of cards' do
        player2.add_card(card)
        game.declare_game_winner
        expect(game.winner).to eq player2
      end

      it 'returns nil if neither player is out of cards' do
        player1.add_card(card)
        player2.add_card(card2)
        game.declare_game_winner
        expect(game.winner).to eq nil
      end
    end

    describe '#game_over?' do
      it 'returns false if both players still have cards' do
        player1.add_card(card)
        player2.add_card(card2)
        expect(game.game_over?).to be false
      end

      it 'returns true when one or more players are out of cards' do
        expect(game.game_over?).to be true
      end
    end
  end
end
