require 'socket'
require_relative './game'
require_relative './player'
require_relative './deck'
require_relative './card'

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

  def run(client) # not tested ?
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
    match = { "game" => game, client1 => player1, client2 => player2 }
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
      tell_starting_state(match)
      round_result = game.play_round
      tell_ending_state(match, round_result)
    end
    congratulate_game(match)
  end

  def tell_starting_state(match)
  end

  def tell_ending_state(match, round_result)
  end

  def congratulate_game(match)
  end

  def stop_connection(client_socket)
    @clients.delete(client_socket)
    @pending_clients.delete(client_socket)
    client_socket.close unless client_socket.closed?
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client } if @clients
    @pending_clients.each { |client| connections << client } if @pending_clients
    connections.each { |client| stop_connection(client) }
    @socket.close if (@socket && !@socket.closed?)
  end
end
