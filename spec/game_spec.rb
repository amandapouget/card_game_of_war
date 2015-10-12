require 'spec_helper'

describe Game do
  before(:each) do
    @player1  = Player.new(name: "Amanda")
    @player2 = Player.new(name: "Vianney")
    @game = Game.new(player1: @player1, player2: @player2)
    @deck = @game.deck
  end

  describe '#initialize' do
    it 'creates a game with two players and a deck full of cards' do
      expect(@game.player1 ).to eq @player1
      expect(@game.player2).to eq @player2
      expect(@game.deck.type).to eq 'regular'
    end
  end

  describe '#player1 ' do
    it 'returns the first player' do
      expect(@game.player1).to eq @player1
    end
  end

  describe '#player2' do
    it 'returns the second player' do
      expect(@game.player2).to eq @player2
    end
  end

  describe '#deal' do #confusing test
    it 'deals the cards to each player until all the cards are dealt' do
      half_the_num_cards = @deck.count_cards / 2
      @game.deal
      player1_dist_from_half = @player1.count_cards - half_the_num_cards
      player2_dist_from_half = @player2.count_cards - half_the_num_cards
      expect(@deck.count_cards).to eq 0
      expect(player1_dist_from_half).to be_within(0.5).of(0.5)
      expect(player2_dist_from_half).to be_within(0.5).of(0.5)
    end
  end

  describe '#play' do
    it 'plays the game until the game is over' do
      @game.deal
      expect(@game.game_over?).to be false
      @game.play
      expect(@game.game_over?).to be true
    end
    it 'makes sure there is a winner declared when play is over' do
      @game.deal
      @game.play
      expect(@game.winner).to_not eq nil
    end
  end

  describe '#play_round' do
    it 'gets a card from each player, compares who won, sends the player his winnings and returns round winner' do
      card1 = Card.new(rank: "two", suit: "spades")
      card2 = Card.new(rank: "ace", suit: "hearts")
      @player1.play_next_card until @player1.out_of_cards?
      @player2.play_next_card until @player2.out_of_cards?
      @player1.add_card(card1)
      @player2.add_card(card2)
      expect(@game.play_round).to eq @player2
      expect(@player1.count_cards).to be 0
      expect(@player2.cards).to match_array [card1, card2]
    end

    it 'in the case of no winner, plays war and successfully finishes the round' do
      card1 = Card.new(rank:"king", suit: "spades")
      card2 = Card.new(rank:"king", suit: "hearts")
      cardhidden1 = Card.new(rank: "jack", suit: "spades")
      cardhidden2 = Card.new(rank: "ace", suit: "diamonds")
      card3 = Card.new(rank: "nine", suit: "diamonds")
      card4 = Card.new(rank: "four", suit: "clubs")

      @player1.play_next_card until @player1.out_of_cards?
      @player2.play_next_card until @player2.out_of_cards?
      @player1.add_card(card1)
      @player2.add_card(card2)
      @player1.add_card(cardhidden1)
      @player2.add_card(cardhidden2)
      @player1.add_card(card3)
      @player2.add_card(card4)

      expect(@game.play_round).to eq @player1
      expect(@player2.count_cards).to be 0
      expect(@player1.cards).to match_array [card1, card2, cardhidden1, cardhidden2, card3, card4]
    end
  end

  describe '#declare_game_winner' do
    it 'returns player1 if player2 is out of cards' do
      @player1.add_card(Card.new(rank: "two", suit: "spades"))
      @player2.add_card(Card.new(rank: "three", suit: "hearts"))
      @player2.play_next_card until @player2.out_of_cards?
      @game.declare_game_winner
      expect(@game.winner).to eq @player1
    end
    it 'returns player2 if player1 is out of cards' do
      @player1.add_card(Card.new(rank: "two", suit: "spades"))
      @player2.add_card(Card.new(rank: "three", suit: "hearts"))
      @player1.play_next_card until @player1.out_of_cards?
      @game.declare_game_winner
      expect(@game.winner).to eq @player2

    end
    it 'returns nil if neither player is out of cards' do
      @player1.add_card(Card.new(rank: "two", suit: "spades"))
      @player2.add_card(Card.new(rank: "three", suit: "hearts"))
      @game.declare_game_winner
      expect(@game.winner).to eq nil
    end
  end

  describe '#game_over?' do
    it 'returns true when one player is out of cards' do
      @player1.play_next_card until @player1.out_of_cards?
      expect(@game.game_over?).to be true
    end
    it 'returns false if both players still have cards' do
      @player1.add_card(Card.new(rank: "two", suit: "spades"))
      @player2.add_card(Card.new(rank: "three", suit: "hearts"))
      expect(@game.game_over?).to be false
    end
  end
end
