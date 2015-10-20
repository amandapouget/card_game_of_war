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
    #discern(@my_output) # this has to be JSON
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
