require 'socket'
require 'pry'

class WarServer
  attr_accessor :server, :socket, :pending_clients, :clients

  def initialize(port:)
    @port = port
    @socket = TCPServer.open('localhost', port)
    @pending_clients = []
    @clients = []
  end

  def start
    Thread.new {
      loop do
        Thread.start(@socket.accept) do |client|
          client.puts 'Welcome to war!'
          @pending_clients << client
          @pending_clients.length
          if @pending_clients.length == 2
              player1_socket = @pending_clients[0]
              player2_socket = @pending_clients[1]
              
              player1_name = ask_for_name(client: player1_socket)
              player2_name = ask_for_name(client: player2_socket)
            @clients << @pending_clients.shift
            @clients << @pending_clients.shift
          end
        end
      end
    }
  end

  def ask_for_name(client:)
    client.puts "What is your name?"
  end
end
