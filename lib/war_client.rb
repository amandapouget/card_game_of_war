=begin
def tell_player_state(client, player)
  client.puts "You have #{match.key(client).count_cards} cards. Hit any key to play round."
end

def give_state(cards_bet = {}, match:, point_in_round:) #suggest eliminating keyword arguments from this
  game = match["game"]
  clients = [match[game.player1], match[game.player2]]
  if point_in_round == "start"
    clients.each { |client| tell_player_state(client, match.key(client)) }
    clients.each { |client| get_input(client) } # how would we deal with edge case where one player stops responding?
  elsif point_in_round == "post_play"
    cards_bet = cards_bet[0]
    player1_cards = []
    player2_cards = []
    cards_bet[game.player1].each { |card| player1_cards << "the " + card.rank + " of " + card.suit }
    cards_bet[game.player2].each { |card| player2_cards << "the " + card.rank + " of " + card.suit }
    player1.puts "You played " + seriesify(player1_cards) + ". Your opponent played " + seriesify(player2_cards) + "."
    player2.puts "You played " + seriesify(player2_cards) + ". Your opponent played " + seriesify(player1_cards) + "."
  end
end

# All this text stuff should happen on the client side. The server side should just send out a round result object. Optional: send roundresult to client as JSON instead of as object.

def seriesify(string_array)
  return "nothing" if string_array.length == 0
  return string_array[0] if string_array.length == 1
  if string_array.length == 2
    return string_array[0] + " and " + seriesify(string_array[1, string_array.length-1])
  elsif string_array.length > 2
    return string_array[0] + ", " + seriesify(string_array[1, string_array.length-1])
  end
end

def congratulate_round(match)
  match[winner].puts "You won!"
  player1 = match["game"].player1
  player2 = match["game"].player2
  if player1 == winner
    match[player2].puts "You lost!"
  else
    match[player1].puts "You lost!"
  end
end

def congratulate_game(match)
end
=end
