require 'spec_helper'

#add test for yield part of playing a round

describe Game do
  context 'game is initialized with two players' do
    let(:player1) { Player.new(name: "Amanda") }
    let(:player2) { Player.new(name: "Vianney") }
    let(:game) { Game.new(player1: player1, player2: player2) }
    let(:card_js) { Card.new(rank: "jack", suit: "spades") }
    let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
    let(:card_ks) { Card.new(rank:"king", suit: "spades") }
    let(:card_kh) { Card.new(rank:"king", suit: "hearts") }

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
        expect(player1.count_cards).to be_within(1).of half_the_deck
        expect(player2.count_cards).to be_within(1).of half_the_deck
        expect(game.deck.count_cards).to eq 0
      end
    end

    describe ("#play_round") do
      it 'increments rounds_played by 1' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        game.play_round
        expect(game.rounds_played).to eq 1
      end

      it 'returns a round result with the game winner if the game is over' do
        player1.add_card(card_js)
        round_result = game.play_round
        expect(round_result.winner).to eq player1
      end

      it 'returns a round result with the round winner and loser if no war' do
        player1.add_card(card_ad)
        player2.add_card(card_js)
        round_result = game.play_round
        expect(round_result.winner).to eq player1
        expect(round_result.loser).to eq player2
      end

      it 'plays war until a winner is found, looking for winner only every other war card per game rules' do
        10.times do
          player1.add_card(card_ks)
          player1.add_card(card_ad)
          player2.add_card(card_kh)
          player2.add_card(card_js)
        end
        player1.add_card(card_js)
        player2.add_card(card_ad)
        round_result = game.play_round
        expect(round_result.winner).to eq player2
      end
    end

    describe '#play_cards' do
      it 'returns a hash with the cards played by each player' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        cards = game.play_cards
        expect(cards[player1]).to eq [card_js]
        expect(cards[player2]).to eq [card_ad]
      end
    end

    describe '#round_winner' do
      it 'returns who won the round' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        cards_on_table = game.play_cards
        expect(game.round_winner(cards_on_table)).to eq player2
      end
      it 'returns "war" if no one won the round' do
        player1.add_card(card_ks)
        player2.add_card(card_kh)
        cards_on_table = game.play_cards
        expect(game.round_winner(cards_on_table)).to eq "war"
      end
    end

    describe '#round_loser' do
      it 'returns who lost the round' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        cards_on_table = game.play_cards
        expect(game.round_loser(cards_on_table)).to eq player1
      end
      it 'returns "war" if no one lost the round' do
        player1.add_card(card_ks)
        player2.add_card(card_kh)
        cards_on_table = game.play_cards
        expect(game.round_loser(cards_on_table)).to eq "war"
      end
    end

    describe '#get_winnings' do
      it 'returns an array of winnings' do
        player1.add_card(card_js)
        player2.add_card(card_ad)
        cards_on_table = game.play_cards
        winnings = [card_js, card_ad]
        expect(game.get_winnings(cards_on_table)).to match_array winnings
      end
    end

    describe '#game_winner' do
      it 'returns player1 if player2 is out of cards' do
        player1.add_card(card_js)
        expect(game.game_winner).to eq player1
      end

      it 'returns player2 if player1 is out of cards' do
        player2.add_card(card_kh)
        expect(game.game_winner).to eq player2
      end

      it 'returns a nullplayer if neither player is out of cards' do
        player1.add_card(card_ad)
        player2.add_card(card_ks)
        expect(game.game_winner).to eq NullPlayer.new
      end
    end

    describe '#game_loser' do
      it 'returns player2 if player2 is out of cards' do
        player1.add_card(card_js)
        expect(game.game_loser).to eq player2
      end

      it 'returns player1 if player1 is out of cards' do
        player2.add_card(card_kh)
        expect(game.game_loser).to eq player1
      end

      it 'returns a nullplayer if neither player is out of cards' do
        player1.add_card(card_ad)
        player2.add_card(card_ks)
        expect(game.game_loser).to eq NullPlayer.new
      end
    end

    describe '#game_over?' do
      it 'returns false if both players still have cards' do
        player1.add_card(card_ad)
        player2.add_card(card_kh)
        expect(game.game_over?).to be false
      end

      it 'returns true when one or more players are out of cards' do
        expect(game.game_over?).to be true
      end
    end
  end
end
