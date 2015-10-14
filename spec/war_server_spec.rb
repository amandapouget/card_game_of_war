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
      server.socket.close
    end
  end

  context 'server and two clients created and connected' do
    before :each do
      @server = WarServer.new
      @server.socket.listen(5)
      @client = MockWarClient.new
      @client2 = MockWarClient.new
      @client_socket = @server.socket.accept
      @client2_socket = @server.socket.accept
    end

    after :each do
      @client_socket.close
      @client2_socket.close
      @server.socket.close
    end

    describe '#pair_players(client)' do
      it 'welcomes the player' do
        @server.pair_players(client_socket: @client_socket)
        expect(@client.output).to include "Welcome to war!"
      end

      it 'puts first player in pending clients' do
        @server.pair_players(client_socket: @client_socket)
        expect(@server.pending_clients[0]).to eq @client_socket
      end

      it 'when second player joins, moves first player to clients with second player' do
        @server.pair_players(client_socket: @client_socket)
        @server.pair_players(client_socket: @client2_socket)
        expect(@server.pending_clients.length).to eq 0
        expect(@server.clients).to eq [@client_socket, @client2_socket]
      end
    end

    describe '#ask_for_name' do
      it 'asks the client for the players name' do
        @server.ask_for_name(client: @client_socket)
        expect(@client.output).to include "What is your name?"
      end
    end

    context 'now the two players are paired' do
      before :each do
        @server.pair_players(client_socket: @client_socket)
        @server.pair_players(client_socket: @client2_socket)
      end

      describe '#ask_for_name' do
        it 'asks the client for the players name' do
          expect(@server.pending_clients.length).to eq 0
          expect(@server.clients).to eq [@client_socket, @client2_socket]
        end
      end
    end
  end
=begin
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
