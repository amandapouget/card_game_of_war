require 'socket'
require 'json'
require_relative './game'
require_relative './player'

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
    client = @socket.accept
    @pending_clients << client
    client.puts "Welcome to war! I will connect you with your partner..."
    client
  end

  def run(client) # NOT TESTED
    if pair_players
      client1 = @clients.last
      client2 = @clients[@clients.length-2]
      play_game(make_game(client1, client2))
      [client1, client2].each { |client| stop_connection(client) }
    end
  end

  def pair_players
    2.times { @clients << @pending_clients.shift } if @pending_clients.length == 2
  end

  def make_game(client1, client2)
    player1 = Player.new(name: get_name(client1))
    player2 = Player.new(name: get_name(client2))
    game = Game.new(player1: player1, player2: player2)
    game.deal
    Match.new(game: game, client1: client1, client2: client2)
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
    while !match.game.game_over?
      tell_match(match)
      match.clients.each { |client| get_input(client) }
      round_result = match.game.play_round
      tell_round(match, round_result)
    end
    tell_match(match)
  end

  def tell_match(match)
    match_info = JSON.dump(match.to_json)
    match.clients.each { |client| client.puts(match_info) }
  end

  def tell_round(match, round_result)
    round_info = JSON.dump(round_result.to_json)
    match.clients.each { |client| client.puts(round_info) }
  end

  def stop_connection(client)
    @clients.delete(client)
    @pending_clients.delete(client)
    client.close unless client.closed?
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client } if @clients
    @pending_clients.each { |client| connections << client } if @pending_clients
    connections.each { |client| stop_connection(client) }
    @socket.close if (@socket && !@socket.closed?)
  end
end
