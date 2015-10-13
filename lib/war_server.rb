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
    end
  end

  def ask_for_name(client: $stdout)
    client.puts "What is your name?"
  end
end
