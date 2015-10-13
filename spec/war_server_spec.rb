require 'spec_helper'
require 'pry'

def capture_stdout(&block)
  old = $stdout
  $stdout = fake = StringIO.new
  block.call
  fake.string
ensure
  $stdout = old
end

describe WarServer do
  describe '#start' do
    it 'starts up the server and thread' do
      server_thread = Thread.new { WarServer.new(port: 2001).start }
      client = MockWarClient.new(port: 2001) # don't understand why port numbers have to be different here
      client.capture_output
      expect(client.output).to eq ("Welcome to war!\n")
      server_thread.terminate # have to do this before joining thread or get stuck in the loop
      #puts server_thread.alive?
      server_thread.join # have to join the thread in order to kill it
      #puts server_thread.alive?
      server_thread.kill
      #puts server_thread.alive? # thread is dead, yet, port still occupied so have to use port 2000 on other tests below. UPDATE: thread isn't dead, just can't tell it's alive because you've joined it
    end
  end

  describe '#initialize' do
    it 'creates a WarServer object with a server' do
      server = WarServer.new(port: 2002)
      expect(server).to be_a WarServer
    end
  end

  describe '#ask_for_name' do
    it 'asks for the players name, gets it, and returns it' do
      server = WarServer.new(port: 2003)
      output = capture_stdout { server.ask_for_name(client: $stdout) }
      expect(output).to eq "What is your name?\n"
    end
  end

  describe '#start' do
    it 'start a game when there are two clients connected' do
      server = WarServer.new(port: 2004)
      server.start
      client = MockWarClient.new(port: 2004)
      client2 = MockWarClient.new(port: 2004)
      sleep(3)
      expect(server.clients.length).to eq 2
    end
  end
end
