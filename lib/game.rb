require './lib/deck.rb'

class Game

  attr_accessor :player1, :player2, :deck, :winner, :rounds_played

  def initialize(player1:, player2:)
    @player1 = player1
    @player2 = player2
    @deck = Deck.new(type: 'regular')
    @winner = nil
    @rounds_played = 0
  end

  def deal
    deck.shuffle
    while !deck.empty?
      player1.add_card(deck.deal_next_card)
      player2.add_card(deck.deal_next_card) unless deck.empty?
    end
  end

  def play_round(state = nil)
    return declare_game_winner if game_over?
    @rounds_played += 1
    cards = play_cards
    yield(cards, match: match, point_in_round: "post-play") if state
    winner = determine_winner(cards_bet: cards)
    if !(winner=="war")
      winner.collect_winnings(get_winnings(cards_bet: cards))
      return winner
    end
    while winner == "war"
      2.times do
        return declare_game_winner if game_over?
        new_cards = play_cards
        cards[@player1] << new_cards[@player1][0]
        cards[@player2] << new_cards[@player2][0]
      end
      yield(cards, match: match, point_in_round: "post-play") if state
      winner = determine_winner(cards_bet: cards)
    end
    yield(cards, match: match, point_in_round: "post-play") if state
    winner.collect_winnings(get_winnings(cards_bet: cards))
    return winner
  end

  def play_cards(cards = { @player1 => [], @player2 => [] })
    cards[@player1] << player1.play_next_card
    cards[@player2] << player2.play_next_card
    return cards
  end

  def determine_winner(cards_bet:)
    player1_cards = cards_bet[@player1]
    player2_cards = cards_bet[@player2]
    return @player1 if player1_cards.last.rank_value > player2_cards.last.rank_value
    return @player2 if player2_cards.last.rank_value > player1_cards.last.rank_value
    return "war"
  end

  def get_winnings(cards_bet:)
    winnings = []
    cards_bet[@player1].each { |card| winnings << card }
    cards_bet[@player2].each { |card| winnings << card }
    winnings.shuffle!
    return winnings
  end

  def declare_game_winner
    @winner = player1 if player2.out_of_cards?
    @winner = player2 if player1.out_of_cards?
    @winner
  end

  def game_over?
    player1.out_of_cards? || player2.out_of_cards?
  end
end
