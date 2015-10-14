require 'socket'

class MockWarClient
  attr_reader :socket

  def initialize(port: 2000)
    @socket = TCPSocket.open('localhost', port)
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
end
