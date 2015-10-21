require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

loop do
  while input = s.gets
    puts input.chop
  end
end

# We would really like help with getting around this looping issue, possibly by using Telnet

require './lib/war_client.rb'

client = Client.new.start
client.puts_welcome
# you'll need a loop here that matches play_game in server, so that the client is outputting at the right moment and sending at the right moment
