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
      Thread.start(@socket.accept) do |client_socket|
        pair_players(client_socket)
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
      #play_game(client1: player1_socket, client2: player2_socket)
    end
  end

  def ask_for_name(client_socket:)
    client_socket.puts "What is your name?"
  end

  def get_name(client_socket:)
    begin
      client_socket.read_nonblock(1000)
    rescue IO::WaitReadable
      IO.select([client_socket])
      retry
    end
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

  def stop_connection(client_socket:)
    @clients.delete(client_socket)
    @pending_clients.delete(client_socket)
    client_socket.close unless client_socket.closed?
  end

  def stop_all_connections(client_sockets:)
    client_sockets.each { |client_socket| stop_connection(client_socket) unless client_socket.closed? }
  end

  def stop_server
    @clients.each { |client| stop_connection(client_socket: client) }
    @pending_clients.each { |client| stop_connection(client_socket: client) }
    @server.close unless @server.closed?
  end
end
