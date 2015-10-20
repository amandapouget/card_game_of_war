require './lib/deck.rb'
require './lib/round_result.rb'

class Game
  attr_accessor :player1, :player2, :deck, :winner, :loser, :rounds_played

  def initialize(player1:, player2:)
    @player1 = player1
    @player2 = player2
    @deck = Deck.new(type: 'regular')
    @winner = nil
    @loser = nil
    @rounds_played = 0
  end

  def deal
    deck.shuffle
    while !deck.empty?
      player1.add_card(deck.deal_next_card)
      player2.add_card(deck.deal_next_card) unless deck.empty?
    end
  end

  def play_round # what beautiful dry code we have!
    return RoundResult.new(winner: game_winner, loser: game_loser) if game_over?
    @rounds_played += 1
    cards = play_cards
    while round_winner(cards) == "war"
      2.times do
        return RoundResult.new(winner: game_winner, loser: game_loser, cards: cards) if game_over?
        cards = play_cards(cards)
      end
    end
    round_winner(cards).collect_winnings(get_winnings(cards))
    return RoundResult.new(winner: round_winner(cards), loser: round_loser(cards), cards: cards)
  end

  def play_cards(cards = { @player1 => [], @player2 => [] })
    cards[@player1] << player1.play_next_card
    cards[@player2] << player2.play_next_card
    return cards
  end

  def round_winner(cards)
    return @player1 if cards[@player1].last.rank_value > cards[@player2].last.rank_value
    return @player2 if cards[@player2].last.rank_value > cards[@player1].last.rank_value
    return "war"
  end

  def round_loser(cards)
    return @player2 if cards[@player1].last.rank_value > cards[@player2].last.rank_value
    return @player1 if cards[@player2].last.rank_value > cards[@player1].last.rank_value
    return "war"
  end

  def get_winnings(cards)
    winnings = []
    cards[@player1].each { |card| winnings << card }
    cards[@player2].each { |card| winnings << card }
    winnings.shuffle!
    return winnings
  end

  def game_winner
    @winner = player1 if player2.out_of_cards?
    @winner = player2 if player1.out_of_cards?
    @winner
  end

  def game_loser
    @loser = player2 if player2.out_of_cards?
    @loser = player1 if player1.out_of_cards?
    @loser
  end

  def game_over?
    player1.out_of_cards? || player2.out_of_cards?
  end
end
