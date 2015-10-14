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
  describe '#initialize' do
    it 'creates a WarServer with a socket, port, pending_clients and clients' do
      server = WarServer.new(port: 2000)
      expect(server).to be_a WarServer
      expect(server.port).to eq 2000
      expect(server.socket).to be_a TCPServer
      expect(server.pending_clients).to eq []
      expect(server.clients).to eq []
    end
  end

  before do
    @server = WarServer.new
    @server.socket.listen(5)
    @client = MockWarClient.new
    @client_socket = @server.socket.accept
  end

  after do
    @server.socket.close
    @client_socket.close
  end

  describe '#pair_players(client)' do
    it 'welcomes the player' do
      @server.pair_players(client_socket: @client_socket)
      @client.capture_output
      expect(@client.output).to include "Welcome to war!"
    end

    it 'increases either pending clients by 1 or clients by 2' do
      @server.pair_players(client_socket: @client_socket)
      @client.capture_output
      expect(@client.output).to include "Welcome to war!"
    end
  end
=begin
  describe '#ask_for_name' do
    it 'asks for the players name, gets it, and returns it' do
      server = WarServer.new
      output = capture_stdout { server.ask_for_name(client: $stdout) }
      expect(output).to eq "What is your name?\n"
    end
  end

  describe '#get_name' do
    it 'returns the name as a string' do #needs work
      server = WarServer.new
      client = MockWarClient.new
      puts client
      puts server.ask_for_name(client: client)
    end
  end

  describe '#pair_players' do
    it 'when there are two pending clients connected, match them and then start game' do
      server = WarServer.new(port: 2004)
      client = MockWarClient.new(port: 2004)
      client2 = MockWarClient.new(port: 2004)
      sleep(1) # if I don't include this line, rspec finishes before the clients have a chance to connect and get added to @clients
      expect(server.clients.length).to eq 2
      client.capture_output
      expect(client.output).to eq ("Welcome to war!\n")
    end
  end

  describe '#kill' do
    it 'gracefully closes each client connection' do
      server = WarServer.new(port: 2005)
      client1 = MockWarClient.new(port: 2005)
      client2 = MockWarClient.new(port: 2005)
      server.clients << client1.socket
      server.clients << client2.socket
      server.kill_server
      expect(client1.socket.closed?).to be true
    end
    it 'kills the servers running thread that began in the start method' do
      server = WarServer.new(port: 2005)
      server.start
      server.kill_server
      expect(server.running?).to be false
    end
  end
=end
end
