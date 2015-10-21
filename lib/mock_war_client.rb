require 'socket'
require 'json'

class MockWarClient
  attr_reader :socket

  def start
    @socket = TCPSocket.open('localhost', 2000)
    # could put your JSON in here to load the welcome message and identifier given by accept in war_server
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @my_output = @socket.read_nonblock(1000)
  rescue IO::WaitReadable
    @my_output = ""
  end

  def output
    capture_output
    @my_output
  end

  def discern(output)
    my_hash = JSON.load(output)
  end
end

=begin
NEXT STEP IS TO MAKE CLIENT MODELED OFF OF MOCK CLIENT
CLIENT MUST:
-- be able to discern JSON using .parse, .load (not recommended)
-- be able to spit things out in nice strings
-- be able to tell the difference between a match and a round_result, and also the difference between the match sent mid-play and that sent at the end of the Game
-- be able to have a user ID given by the server (do last)
=end
