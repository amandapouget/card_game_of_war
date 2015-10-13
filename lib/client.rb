=begin
require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

while receiving = s.gets
  puts receiving
  while sending = gets
    s.puts sending
  end
end

def capture_stdout(&blk)
  old = $stdout
  $stdout = StringIO.new
  blk.call
  $stdout.string
ensure
  $stdout = old
end


require 'socket'               # Get sockets from stdlib

class WarServer

  def initialize(port:, hostname: localhost)
    @server = TCPServer.open(localhost, port)   # Socket to listen on port 2000
  end

  def start
    puts "server starts listening..."
    loop do                          # Servers run forever
      Thread.start(@server.accept) do |client|
        client.puts(Time.now.ctime)  # Send the time to the client
    	  client.puts "Enter your name: "
        puts "User entered: #{client.gets.chomp.chomp.chomp}" # I don't understand why I get extra lines
        client.puts "I got your message! #{client.gets.chomp}"
        client.puts "Play war now!"
        # play game
        client.close                 # Disconnect from the client
      end
    end
  end
end



client = MockWarClient.new(2000)
while x = client.capture_output
  puts x
  client.provide_input(gets.chomp)
end
=end
