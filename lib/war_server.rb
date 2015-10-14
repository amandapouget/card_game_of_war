require 'socket'
require 'pry'

class WarServer
  attr_accessor :port, :socket, :pending_clients, :clients

  def initialize(port: 2000)
    @port = port
    @socket = TCPServer.open('localhost', port)
    @pending_clients = []
    @clients = []
  end

  def start
    loop do
      Thread.start(@socket.accept) do |client|
        pair_players(client)
      end
    end
  end

  def pair_players(client)
    client.puts 'Welcome to war!'
    ask_for_name(client: client)
    name = get_name(client: client)
    # have to make a way to store the name and the client together
    @pending_clients << client
    if @pending_clients.length == 2
      player1_socket = @pending_clients[0]
      player2_socket = @pending_clients[1]
      @clients << @pending_clients.shift
      @clients << @pending_clients.shift
      play_game(client1: player1_socket, client2: player2_socket)
    end
  end

  def ask_for_name(client:)
    client.puts "What is your name?"
  end

  def get_name(client:)

  end

  def play_game(client1:, client2:)
    ask_for_name(client: client1)
    player1_name = get_name(client: client1)
    player1 = Player.new(name: player1_name)

    ask_for_name(client: client2)
    player2_name = get_name(client: client2)
    player2 = Player.new(name: player2_name)

    game = Game.new(player1: player1, player2: player2)
    #play rounds [print stuff to client, get next move?]
    #until game is over
    #declare winner
    #close connections
  end

  def stop_connection(client)
    client.close
  end

  def stop_all_connections(clients)
    clients.each { |client| stop_connection(client) }
  end
end
