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
    @socket = TCPServer.open('localhost', port)
    @pending_clients = []
    @clients = []
    @game = nil
  end

  def start
    loop do
      Thread.start(@socket.accept) do |client_socket|
        pair_players(client_socket: client_socket)
        if @clients.length == 2
          make_game
          run_game
          stop_connection(client_socket: @clients[0])
          stop_connection(client_socket: @clients[0])
        end
        # Need a Thread.kill here?
      end
    end
  end

  def pair_players(client_socket:)
    client_socket.puts "Welcome to war! I will connect you with your partner..."
    @pending_clients << client_socket
    if @pending_clients.length == 2
      player1_socket = @pending_clients[0]
      player2_socket = @pending_clients[1]
      @clients << @pending_clients.shift
      @clients << @pending_clients.shift
    end
  end

  def ask_for_name(client_socket:)
    client_socket.puts "What is your name?"
  end

  def get_name(client_socket:)
    begin
      client_socket.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client_socket])
      retry
    end
  end

  def make_game
    ask_for_name(client_socket: @clients[0])
    player1_name = get_name(client_socket: @clients[0])
    player1 = Player.new(name: player1_name)

    ask_for_name(client_socket: @clients[1])
    player2_name = get_name(client_socket: @clients[1])
    player2 = Player.new(name: player2_name)
    #my_client = WarClient.new(player: player1, name: name, socket: client1)
    @game = Game.new(player1: player1, player2: player2)
  end

  def run_game
    @game.deal
    while !@game.game_over?
      round_winner = game.play_round
      congratulate_round(winner: round_winner)
    end
    congratulate_game(winner: @game.declare_game_winner)
  end

  def congratulate_round(winner:)
    if @game.player1 == winner
      @clients[0].puts "You won!"
      @clients[1].puts "You lost!"
    else
      @clients[0].puts "You lost!"
      @clients[1].puts "You won!"
    end
  end

  def congratulate_game(winner:)
    if @game.player1 == winner
      @clients[0].puts "You won the game!"
      @clients[1].puts "You lost the game!"
    else
      @clients[0].puts "You lost the game!"
      @clients[1].puts "You won the game!"
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
