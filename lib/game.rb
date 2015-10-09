class Game

  attr_reader :player1, :player2, :deck, :winner

  def initialize(players)
    @player1 = players[:player1]
    @player2 = players[:player2]
    @deck = Deck.new
    @winner = nil
  end

  def deal
    deck.shuffle
    loop do
      player1.add_card(deck.deal_next_card) unless deck.empty?
      player2.add_card(deck.deal_next_card) unless deck.empty?
      break if deck.empty?
    end
  end

  def play
    loop do
      play_round
      break if game_over?
    end
    declare_game_winner
  end

  def play_round(cards_bet = [])
    cards_on_table = cards_bet
    player1_card = player1.play_next_card
    player2_card = player2.play_next_card
    cards_on_table << player1_card
    cards_on_table << player2_card

    if player1_card.rank_numeric_value > player2_card.rank_numeric_value
      winner = player1
      winner.collect_winnings(cards_on_table)
    elsif player2_card.rank_numeric_value > player1_card.rank_numeric_value
      winner = player2
      winner.collect_winnings(cards_on_table)
    else
      hidden_card1 = player1.play_next_card
      hidden_card2 = player2.play_next_card
      hidden_card1.turn_over
      hidden_card2.turn_over
      cards_on_table << hidden_card1
      cards_on_table << hidden_card2
      winner = play_round(cards_on_table)
    end
    return winner
  end

  def declare_game_winner
    @winner = player1 if player2.out_of_cards?
    @winner = player2 if player1.out_of_cards?
  end

  def game_over?
    player1.out_of_cards? || player2.out_of_cards?
  end
end
