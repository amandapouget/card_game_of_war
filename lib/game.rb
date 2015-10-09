class Game

  attr_reader :player1, :player2, :deck, :winner

  def initialize(players)
    @player1 = players[:player1]
    @player2 = players[:player2]
    @deck = Deck.new
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

  def play
    while !game_over?
      play_round
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
      cards_on_table.shuffle!
      winner.collect_winnings(cards_on_table)
    elsif player2_card.rank_numeric_value > player1_card.rank_numeric_value
      winner = player2
      cards_on_table.shuffle!
      winner.collect_winnings(cards_on_table)
    elsif game_over?
      return
    else
      hidden_card1 = player1.play_next_card
      hidden_card2 = player2.play_next_card
      cards_on_table << hidden_card1
      cards_on_table << hidden_card2
      winner = play_round(cards_on_table) unless game_over?
    end
    @rounds_played += 1
    return winner
  end

  def declare_game_winner
    @winner = player1 if player2.out_of_cards?
    @winner = player2 if player1.out_of_cards?
    puts @winner.name unless @winner == nil
    @winner
  end

  def game_over?
    player1.out_of_cards? || player2.out_of_cards?
  end
end
