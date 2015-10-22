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
    let(:server) { WarServer.new }
    let(:client) { MockWarClient.new() }
    let(:client2){ MockWarClient.new() }

    describe '#initialize' do
      it 'creates a WarServer on a default port' do
        expect(server).to be_a WarServer
        expect(server.port).to eq 2000
      end

      it 'is not listening when it is created' do
        begin
          client.start
        rescue => e
          expect(e.message).to match(/connection refused/i)
        end
      end
    end

    context 'server started' do
      before do
        server.start
      end

      after :each do
        server.stop_server
      end

      describe '#start' do
        it 'starts the server by giving it a TCP server and arrays of pending_users and clients' do
          expect(server.socket).to be_a TCPServer
          expect(server.pending_users).to eq []
          expect(server.clients).to eq []
        end

        it 'is listening when started and connects to a client' do
          expect{ client.start }.to_not raise_exception
        end

        it 'when started, connects to multiple clients at once' do
          client.start
          expect{ client2.start }.to_not raise_exception
        end
      end

      context 'two clients are started' do
        before :each do
          client.start
          client2.start
        end

        describe '#accept' do
          it 'accepts the client and welcomes the player' do
            server.accept
            expect(client.output).to include "Welcome to war!"
          end

          it 'accepts two clients and welcomes both players' do
            server.accept
            expect(client.output).to include "Welcome to war!"
            server.accept
            expect(client2.output).to include "Welcome to war!"
          end

          it 'adds the client to clients' do
            client_socket = server.accept
            expect(server.clients[0]).to eq client_socket
          end
        end

        describe '#player_pair_ready?' do
          it 'returns false when only one player is connected' do
            server.accept
            expect(server.player_pair_ready?).to be_falsey
          end
        end
      end

      context 'two clients are accepted and users connected to clients exist' do
        let(:user1) { User.new(client: @client_socket) }
        let(:user2) { User.new(client: @client2_socket) }

        before do
          client.start
          client2.start
          @client_socket = server.accept
          @client2_socket = server.accept
        end

        describe '#get_id' do
          it 'asks for a unique id and takes client input' do
            client.provide_input("\n")
            server.get_id(@client_socket)
            expect(client.output).to include "Please enter your unique id or hit enter to create a new user."
          end
        end

        describe '#get_name' do
          it 'asks the client for the players name and returns it as a string' do
            client.provide_input("Amanda")
            name = server.get_name(@client_socket)
            expect(client.output).to include "What is your name?"
            expect(name).to eq "Amanda"
          end
        end

        describe '#match_user' do
          it 'returns a user based on id if a good user id # is given' do
            client2.provide_input("\n")
            expect(server.match_user(@client2_socket, user1.id)).to eq user1
          end

          it 'returns a new user with name if no good user id # is given and tells the client its user id' do
            client.provide_input("\n")
            expect(server.match_user(@client_socket, 0)).to be_a User
            expect(client.output).to include "Your unique id is"
          end

          it 'sets the user.client to the client_socket' do
            client.provide_input("\n")
            user = server.match_user(@client_socket, 0)
            expect(user.client).to be_a TCPSocket
          end
        end

        describe '#player_pair_ready?' do
          it 'returns true when two or more users are waiting to join a game' do
            server.pending_users << user1
            server.pending_users << user2
            expect(server.player_pair_ready?).to be true
            server.pending_users << User.new
            expect(server.player_pair_ready?).to be true
          end

          it 'returns false when there are less than two users waiting to join a game' do
            expect(server.player_pair_ready?).to be false
            server.pending_users << user1
            expect(server.player_pair_ready?).to be false
          end
        end

        describe '#make_match' do
          it 'takes two users and returns a match object with an a Game and Players corresponding to the users' do
            match = server.make_match(user1, user2)
            expect(match).to be_a Match
          end

          it 'changes the users current_match to this match' do
            match = server.make_match(user1, user2)
            expect(user1.current_match).to eq match
            expect(user2.current_match).to eq match
          end
        end

        context 'match is made' do
          let(:player1) { Player.new }
          let(:player2) { Player.new }
          let(:game) { match.game }
          let(:match) { server.make_match(user1, user2) }
          let(:round_result) { RoundResult.new(winner: player1, loser: player2) }

          describe '#ask_to_start_match' do
            it 'asks the two clients to hit enter to play' do
              client.provide_input("\n")
              client2.provide_input("\n")
              server.ask_to_start_match(match)
              expect(client.output).to include "Hit enter to play!"
            end
          end

          context 'players each one have one card to play a round' do
            before do
              game.player1.add_card(Card.new(rank: "ace", suit: "spades"))
              game.player2.add_card(Card.new(rank: "jack", suit: "spades"))
            end

            describe '#play_match' do
              it 'plays the game until over' do
                client.provide_input("\n")
                client2.provide_input("\n")
                server.play_match(match)
                expect(game.game_over?).to be true
              end
            end

            describe 'find_client' do # successfully test if you can reconnect a user!
              it 'rejoins a lost user to the game it was in before it was disconnected' do
                server.stop_connection(@client2_socket)
                client2.start
                new_socket = server.accept
                server.match_user(new_socket, user2.id)
                client.provide_input("\n")
                client2.provide_input("\n")
                server.play_match(match)
                expect(match.game.game_over?).to be true
              end

              # successfully test the timeout!
              it 'ends the match if a user takes more than a given number of seconds to respond' do
                client.provide_input("\n")
                server.play_match(match, 0.1)
                expect(client.output).to include "Game forfeited!"
              end
            end
          end

          describe '#tell_match' do
            it 'sends both match clients a json hash with info about the match' do
              server.tell_match(match)
              expect(client.output).to include JSON.dump(match.to_json)
              expect(client2.output).to include JSON.dump(match.to_json)
            end
          end

          describe '#tell_round' do
            it 'sends both match clients a json hash with info about the round' do
              server.tell_round(match, round_result)
              expect(client.output).to include JSON.dump(round_result.to_json)
              expect(client2.output).to include JSON.dump(round_result.to_json)
            end
          end

          describe '#stop_connection' do
            it 'closes the client connection to the server unless client already closed' do
              expect(@client_socket.closed?).to be false
              server.stop_connection(@client_socket)
              expect(@client_socket.closed?).to be true
            end

            it 'removes the connection from clients if it is in clients' do
              server.clients << @client_socket
              expect(server.clients.include?(@client_socket)).to be true
              server.stop_connection(@client_socket)
              expect(server.clients.include?(@client_socket)).to be false
            end
          end

          describe '#stop_server' do
            it 'closes all the connections in clients and removes them from clients' do
              server.stop_server
              expect(@client_socket.closed?).to be true
              expect(@client2_socket.closed?).to be true
              expect(server.clients.length).to eq 0
            end

            it 'removes all the pending users' do
              server.pending_users << user1
              server.pending_users << user2
              server.stop_server
              expect(server.pending_users).to eq []
            end

            it 'closes the server socket' do
              server.stop_server
              expect(server.socket.closed?).to be true
            end
          end
        end
      end
    end
  end
end
