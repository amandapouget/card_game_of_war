require 'socket'

class WarServer
  attr_accessor :server, :socket

  def initialize(port:)
    @port = port
    @socket = TCPServer.open(port)
  end

  def start
    loop do
      Thread.start(@socket.accept) do |client|
        client.puts 'Welcome to war!'
      end
      sleep(0.01)
    end
  end

  def ask_for_name(client: $stdout)
    client.puts "What is your name?"
  end

  def start_game(player1, player2)
    @game = Game.new()
  end

end
