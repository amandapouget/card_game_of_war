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
