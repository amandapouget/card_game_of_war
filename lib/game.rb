require 'deck'

class Game

  attr_reader :player1, :player2, :deck, :winner, :rounds_played

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

  def play_round(cards_bet = [])
    return declare_game_winner if game_over?
    cards_on_table = cards_bet
    player1_card = player1.play_next_card
    player2_card = player2.play_next_card
    cards_on_table << player1_card
    cards_on_table << player2_card

    if player1_card.rank_value > player2_card.rank_value
      cards_on_table.shuffle!
      winner = player1
      winner.collect_winnings(cards_on_table)
      @rounds_played += 1
      return winner
    elsif player2_card.rank_value > player1_card.rank_value
      cards_on_table.shuffle!
      winner = player2
      winner.collect_winnings(cards_on_table)
      @rounds_played += 1
      return winner
    elsif game_over?
      @rounds_played += 1
      return declare_game_winner
    else
      cards_on_table << player1.play_next_card
      cards_on_table << player2.play_next_card
      winner = play_round(cards_on_table)
    end
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
