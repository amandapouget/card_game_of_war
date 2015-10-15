require 'spec_helper'

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
      @client = MockWarClient.new
      @client2 = MockWarClient.new
      @client_socket = @server.socket.accept
      @client2_socket = @server.socket.accept
    end

    after :each do
      @server.stop_server
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
        @server.ask_for_name(client_socket: @client_socket)
        expect(@client.output).to include "What is your name?"
      end
    end

    describe '#get_name' do
      it 'returns the name as a string' do #needs work
        @client.provide_input("Amanda")
        name = @server.get_name(client_socket: @client_socket)
        expect(name).to eq "Amanda"
      end
    end

    describe '#make_game' do
      it 'returns a game made from clients[0] and clients[1]' do
        @server.clients << @client_socket
        @server.clients << @client2_socket
        @client.provide_input("Amanda")
        @client2.provide_input("Vianney")
        expect(@server.make_game).to be_a Game
      end
    end

    context 'game is made' do
      before :each do
        @server.clients << @client_socket
        @server.clients << @client2_socket
        @client.provide_input("Amanda")
        @client2.provide_input("Vianney")
        @game = @server.make_game
      end

      describe '#run_game' do
        it 'calls game.deal and plays the game until over' do
          expect(@game.deck.count_cards).to eq 52
          @server.run_game
          expect(@game.deck.count_cards).to eq 0
          expect(@game.game_over?).to be true
        end
      end

      describe '#congratulate_round' do
        it 'congratulates only the winner' do
          @server.congratulate_round(winner: @game.player1)
          expect(@client.output).to include "You won!"
          expect(@client2.output).not_to include "You won!"
        end
        it 'condolences only the loser' do
          @server.congratulate_round(winner: @game.player2)
          expect(@client.output).to include "You lost!"
          expect(@client2.output).not_to include "You lost!"
        end
      end

      describe '#congratulate_game' do
        it 'congratulates only the game winner' do
          @server.congratulate_game(winner: @game.player1)
          expect(@client.output).to include "You won the game!"
          expect(@client2.output).not_to include "You won the game!"
        end
        it 'condolences only the game loser' do
          @server.congratulate_game(winner: @game.player2)
          expect(@client.output).to include "You lost the game!"
          expect(@client2.output).not_to include "You lost the game!"
        end
      end
    end

    describe '#stop_connection' do
      it 'closes the client connection to the server unless client already closed' do
        expect(@client_socket.closed?).to be false
        @server.stop_connection(client_socket: @client_socket)
        expect(@client_socket.closed?).to be true
      end

      it 'removes the connection from pending clients if it is in pending clients' do
        @server.pending_clients << @client_socket
        expect(@server.pending_clients.include?(@client_socket)).to be true
        @server.stop_connection(client_socket: @client_socket)
        expect(@server.pending_clients.include?(@client_socket)).to be false
      end

      it 'removes the connection from clients if it is in clients' do
        @server.clients << @client_socket
        expect(@server.clients.include?(@client_socket)).to be true
        @server.stop_connection(client_socket: @client_socket)
        expect(@server.clients.include?(@client_socket)).to be false
      end
    end

    describe '#stop_server' do
      it 'closes all the connections in clients' do
        @server.clients << @client_socket
        @server.clients << @client2_socket
        @server.stop_server
        expect(@client_socket.closed?).to be true
        expect(@client2_socket.closed?).to be true
      end

      it 'closes all the connections in pending clients' do
        @server.pending_clients << @client_socket
        @server.pending_clients << @client2_socket
        @server.stop_server
        expect(@client_socket.closed?).to be true
        expect(@client2_socket.closed?).to be true
      end

      it 'closes the server socket' do
        @server.stop_server
        expect(@server.socket.closed?).to be true
      end
    end
  end
end
