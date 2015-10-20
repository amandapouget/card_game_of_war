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
  context 'create server' do
    before do
      @server = WarServer.new()
      @client = MockWarClient.new()
      @client2 = MockWarClient.new()
    end

    after :each do
      @server.stop_server
    end

    describe '#initialize' do
      it 'creates a WarServer on a default port' do
        expect(@server).to be_a WarServer
        expect(@server.port).to eq 2000
      end

      it 'is not listening when it is created' do
        begin
          @client.start
        rescue => e
          expect(e.message).to match(/connection refused/i)
        end
      end
    end

    describe '#start' do
      it 'starts the server by giving it a TCP server and arrays of pending_clients and clients' do
        @server.start
        expect(@server.socket).to be_a TCPServer
        expect(@server.pending_clients).to eq []
        expect(@server.clients).to eq []
      end

      it 'is listening when started and connects to a client' do
        @server.start
        @client.start
        expect{ @client.start }.to_not raise_exception
      end

      it 'when started, connects to multiple clients at once' do
        @server.start
        @client.start
        expect{ @client2.start }.to_not raise_exception
      end
    end

    context 'server and two clients are started' do
      before :each do
        @server.start
        @client.start
        @client2.start
      end

      describe '#accept' do
        it 'accepts the client and welcomes the player' do
          client_socket = @server.accept
          expect(@client.output).to include "Welcome to war!"
        end

        it 'accepts two clients and welcomes both players' do
          @server.accept
          expect(@client.output).to include "Welcome to war!"
          @server.accept
          expect(@client2.output).to include "Welcome to war!"
        end

        it 'adds the client to pending_clients' do
          client_socket = @server.accept
          @server.run(client_socket)
          expect(@server.pending_clients[0]).to eq client_socket
        end
      end

      describe '#pair_players' do
        it 'returns false when only one player is connected' do
          @server.accept
          expect(@server.pair_players).to be_falsey
        end
      end

      context 'two clients are accepted' do
        before do
          @client_socket = @server.accept
          @client2_socket = @server.accept
        end

        describe '#run' do
          it 'runs the game and then disconnects the clients when it is over' do
            expect(@client_socket.closed?).to be false
            expect(@client2_socket.closed?).to be false
            @client.provide_input("Amanda")
            @client2.provide_input("Vianney")
            @server.run(@client1_socket)
            @server.run(@client2_socket)
            expect(@client_socket.closed?).to be true
            expect(@client2_socket.closed?).to be true
          end
        end

        describe '#pair_players' do
          it 'when second player is accepted, moves first player and second player to clients and returns true' do
            expect(@server.pair_players).to be_truthy
            expect(@server.pending_clients.length).to eq 0
            expect(@server.clients).to eq [@client_socket, @client2_socket]
          end
        end

        context 'clients are paired' do
          before :each do
            @server.pair_players
          end

          describe '#get_name' do
            it 'asks the client for the players name and returns it as a string' do
              @client.provide_input("Amanda")
              name = @server.get_name(@client_socket)
              expect(@client.output).to include "What is your name?"
              expect(name).to eq "Amanda"
            end
          end

          describe '#make_game' do
            it 'takes two client sockets, gets names, creates players and game with cards dealt and returns a hash of game and players corresponding to client sockets' do
              @client.provide_input("Amanda")
              @client2.provide_input("Vianney")
              match = @server.make_game(@client_socket, @client2_socket)
              expect(match).to be_a Hash
              expect(match[@client_socket]).to be_a Player
              expect(match[@client2_socket]).to be_a Player
              expect(match[@client_socket].name).to eq "Amanda"
              expect(match[@client2_socket].name).to eq "Vianney"
              expect(match["game"]).to be_a Game
            end
          end

          context 'game is made' do
            before :each do
              game = Game.new(player1: Player.new, player2: Player.new)
              @match = { "game" => game, @client_socket => game.player1, @client2_socket => game.player2 }
              @client.provide_input("\n")
              @client2.provide_input("\n")
            end

            let(:game) { @match["game"] }
            let(:player1) { game.player1 }
            let(:player2) { game.player2 }
            let(:card_as) { Card.new(rank: "ace", suit: "spades") }
            let(:card_js) { Card.new(rank: "jack", suit: "spades") }
            let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
            let(:card_ks) { Card.new(rank: "king", suit: "spades") }
            let(:card_kh) { Card.new(rank: "king", suit: "hearts") }
            let(:card_2c) { Card.new(rank: "two", suit: "hearts")}

            describe '#play_game' do
              it 'plays the game until over' do
                player1.add_card(card_as)
                player2.add_card(card_js)
                @server.play_game(@match)
                expect(game.game_over?).to be true
              end
            end

            describe '#tell_starting_state' do
            end

            describe '#tell_ending_state' do
            end

            describe '#stop_connection' do
              it 'closes the client connection to the server unless client already closed' do
                expect(@client_socket.closed?).to be false
                @server.stop_connection(@client_socket)
                expect(@client_socket.closed?).to be true
              end

              it 'removes the connection from pending clients if it is in pending clients' do
                @server.pending_clients << @client_socket
                expect(@server.pending_clients.include?(@client_socket)).to be true
                @server.stop_connection(@client_socket)
                expect(@server.pending_clients.include?(@client_socket)).to be false
              end

              it 'removes the connection from clients if it is in clients' do
                @server.clients << @client_socket
                expect(@server.clients.include?(@client_socket)).to be true
                @server.stop_connection(@client_socket)
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
      end
    end
  end
end
