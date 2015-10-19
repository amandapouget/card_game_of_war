require 'socket'
require_relative './game'
require_relative './player'
require_relative './deck'
require_relative './card'

# use hash for client - player relationship
# write tests for behaviors not tests for methods
# find a way to spit back the state of the game between rounds to the client
# the tests should tell me how to use the class not how to use each method of the class
# put "protected" on far left ahead of all methods that someone USING the class should not be able to access. In Ken's example, only start, run, stop... are accessible.
# how to call a protected method from inside a test: server.send(:my_protected_method)
# but if you can so easily skirt protected, what is its purpose?
# the outside world can't access your code, only what you make available through API
# the purpose of protecting something is to inform the developer of things that they probably shouldn't include in the API.
# let(:symbol) is generally for variable declaration.... if you have:
# let(:do_it) { call my method and do stuff in here } and then somewhere in your tests, you call:
#   do_it
#   do_it
# it won't execute the second time because let only executes one time; the second time it decides not to because it already did that.... instead, use a helper method

class WarServer
  attr_accessor :port, :socket, :pending_clients, :clients, :game

  def initialize(port: 2000)
    @port = port
  end

  def start
    @socket = TCPServer.open('localhost', @port)
    @pending_clients = []
    @clients = []
  end

  def make_threads # not tested
    until @socket.closed? do
      Thread.start(accept) { |client| run(client) }
    end
  end

  def accept
    @socket.accept
  end

  def run(client) # not tested ?
    welcome(client)
    if pair_players
      match = make_game(clients.last, clients[clients.length-2])
      match["game"].deal
      play_game(match)
      stop_connection(client_socket: match[match["game"].player1])
      stop_connection(client_socket: match[match["game"].player2])
    end
  end

  def welcome(client)
    client.puts "Welcome to war! I will connect you with your partner..."
    @pending_clients << client
  end

  def pair_players
    if @pending_clients.length == 2
      player1_socket = @pending_clients[0]
      player2_socket = @pending_clients[1]
      @clients << @pending_clients.shift
      @clients << @pending_clients.shift
      return true
    end
    return false
  end

  def make_game(client1, client2)
    player1_name = get_name(client1)
    player1 = Player.new(name: player1_name)

    player2_name = get_name(client2)
    player2 = Player.new(name: player2_name)
    game = Game.new(player1: player1, player2: player2)
    match = { "game" => game, player1 => client1, player2 => client2 }
  end

  def get_name(client)
    client.puts "What is your name?"
    get_input(client)
  end

  def get_input(client)
    begin
      client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
    end
  end

  def play_game(match)
    game = match["game"]
    while !game.game_over?
      give_state(match: match, point_in_round: "start")
      winner = game.play_round { give_state(match: match) }
      congratulate_round(match: match, winner: winner)
    end
    congratulate_game(match: match, winner: game.declare_game_winner)
  end

  def give_state(*cards_bet, match:, point_in_round:)
    game = match["game"]
    player1 = match[game.player1]
    player2 = match[game.player2]
    if point_in_round == "start"
      player1.puts "You have #{game.player1.count_cards} cards. Hit any key to play round."
      player2.puts "You have #{game.player2.count_cards} cards. Hit any key to play round."
      [player1, player2].each { |player| get_input(player) } # how would we deal with edge case where one player stops responding?
    elsif point_in_round == "post_play"
      cards_bet = cards_bet[0]
      player1_cards = []
      player2_cards = []
      cards_bet[game.player1].each { |card| player1_cards << "the " + card.rank + " of " + card.suit }
      cards_bet[game.player2].each { |card| player2_cards << "the " + card.rank + " of " + card.suit }
      player1.puts "You played " + series_ify(player1_cards) + ". Your opponent played " + series_ify(player2_cards) + "."
      player2.puts "You played " + series_ify(player2_cards) + ". Your opponent played " + series_ify(player1_cards) + "."
    end
  end

  def series_ify(string_array)
    return "nothing" if string_array.length == 0
    return string_array[0] if string_array.length == 1
    if string_array.length == 2
      return string_array[0] + " and " + series_ify(string_array[1, string_array.length-1])
    elsif string_array.length > 2
      return string_array[0] + ", " + series_ify(string_array[1, string_array.length-1])
    end
  end

  def congratulate_round(match:, winner:)
    match[winner].puts "You won!"
    player1 = match["game"].player1
    player2 = match["game"].player2
    if player1 == winner
      match[player2].puts "You lost!"
    else
      match[player1].puts "You lost!"
    end
  end

  def congratulate_game(match:, winner:)
    match[winner].puts "You won the game!"
    player1 = match["game"].player1
    player2 = match["game"].player2
    if player1 == winner
      match[player2].puts "You lost the game!"
    else
      match[player1].puts "You lost the game!"
    end
  end

  def stop_connection(client_socket:)
    @clients.delete(client_socket)
    @pending_clients.delete(client_socket)
    client_socket.close unless client_socket.closed?
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client }
    @pending_clients.each { |client| connections << client }
    connections.each { |client| stop_connection(client_socket: client) }
    @socket.close unless @socket.closed?
  end
end
