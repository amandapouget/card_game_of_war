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
    let(:server) { WarServer.new() }
    let(:client) { MockWarClient.new() }
    let(:client2) { MockWarClient.new() }

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

    describe '#start' do
      it 'starts the server by giving it a TCP server and arrays of pending_clients and clients' do
        server.start
        expect(server.socket).to be_a TCPServer
        expect(server.pending_clients).to eq []
        expect(server.clients).to eq []
        server.socket.close
      end

      it 'is listening when started and connects to a client' do
        server.start
        client.start
        expect{ client.start }.to_not raise_exception
        client.socket.close
        server.socket.close
      end

      it 'when started, connects to multiple clients at once' do
        server.start
        client.start
        expect{ client2.start }.to_not raise_exception
        client.socket.close
        client2.socket.close
        server.socket.close
      end
    end
  end

  context 'server and two clients are started' do
    before :each do
      @server = WarServer.new
      @client = MockWarClient.new
      @client2 = MockWarClient.new
      @server.start
      @client.start
      @client2.start
    end

    after :each do
      @server.stop_server
    end

    describe '#accept, #welcome' do
      it 'accepts the client and welcomes the player' do
        client_socket = @server.accept
        @server.welcome(client_socket)
        expect(@client.output).to include "Welcome to war!"
      end

      it 'accepts two clients and welcomes both players' do
        client_socket = @server.accept
        @server.welcome(client_socket)
        expect(@client.output).to include "Welcome to war!"
        client_socket = @server.accept
        @server.welcome(client_socket)
        expect(@client2.output).to include "Welcome to war!"
      end

      it 'adds the client to pending_clients' do
        client_socket = @server.accept
        @server.welcome(client_socket)
        expect(@server.pending_clients[0]).to eq client_socket
      end
    end

    describe '#pair_players' do
      it 'returns false when only one player is connected' do
        client_socket = @server.accept
        @server.welcome(client_socket)
        expect(@server.pair_players).to be false
      end

      it 'when second player joins, moves first player and second player to clients and returns true' do
        client_socket = @server.accept
        client2_socket = @server.accept
        @server.welcome(client_socket)
        @server.welcome(client2_socket)
        expect(@server.pair_players).to be true
        expect(@server.pending_clients.length).to eq 0
        expect(@server.clients).to eq [client_socket, client2_socket]
      end
    end
  end

  context 'server and two clients are started, connected and paired' do
    before :each do
      @server = WarServer.new
      @client = MockWarClient.new
      @client2 = MockWarClient.new
      @server.start
      @client.start
      @client2.start
      @client_socket = @server.accept
      @client2_socket = @server.accept
      @server.welcome(@client_socket)
      @server.welcome(@client2_socket)
      @server.pair_players
    end

    after :each do
      @server.stop_server
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
      it 'takes two client sockets, gets names, creates players and game and returns a hash of game and players corresponding to client sockets' do
        @client.provide_input("Amanda")
        @client2.provide_input("Vianney")
        match = @server.make_game(@client_socket, @client2_socket)
        expect(match).to be_a Hash
        expect(match["game"]).to be_a Game
        player1 = match["game"].player1
        player2 = match["game"].player2
        expect(match[player1]).to be_a TCPSocket
        expect(match[player2]).to be_a TCPSocket
      end
    end
  end

  context 'game is made' do
    before :each do
      @server = WarServer.new
      @client = MockWarClient.new
      @client2 = MockWarClient.new
      @server.start
      @client.start
      @client2.start
      @client_socket = @server.accept
      @client2_socket = @server.accept
      @server.clients << @client_socket
      @server.clients << @client2_socket
      @client.provide_input("Amanda")
      @client2.provide_input("Vianney")
      @match = @server.make_game(@server.clients[0], @server.clients[1])
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

    after :each do
      @server.stop_server
    end

    describe '#play_game' do
      it 'plays the game until over' do
        player1.add_card(card_as)
        player2.add_card(card_js)
        @server.play_game(@match)
        expect(game.game_over?).to be true
      end
    end

    describe '#give_state' do
      it 'if point_in_round is start, informs players of how many cards they have and invites them to hit any key to start round' do
        @server.give_state(match: @match, point_in_round: "start")
        expect(@client.output).to include "You have 0 cards. Hit any key to play round."
        expect(@client2.output).to include "You have 0 cards. Hit any key to play round."
      end
      it 'if point_in_round is post_play, informs players who played what card' do
        cards_bet = { player1 => [card_as], player2 => [card_kh] }
        @server.give_state(cards_bet, match: @match, point_in_round: "post_play")
        expect(@client.output).to include "You played the #{card_as.rank} of #{card_as.suit}. Your opponent played the #{card_kh.rank} of #{card_kh.suit}."
        expect(@client2.output).to include "You played the #{card_kh.rank} of #{card_kh.suit}. Your opponent played the #{card_as.rank} of #{card_as.suit}."
      end
      it 'works for multiple cards played' do
        cards_bet = { player1 => [card_as, card_js, card_ad], player2 => [card_kh, card_ks, card_2c] }
        @server.give_state(cards_bet, match: @match, point_in_round: "post_play")
        expect(@client.output).to include "You played the #{card_as.rank} of #{card_as.suit}, the #{card_js.rank} of #{card_js.suit} and the #{card_ad.rank} of #{card_ad.suit}. Your opponent played the #{card_kh.rank} of #{card_kh.suit}, the #{card_ks.rank} of #{card_ks.suit} and the #{card_2c.rank} of #{card_2c.suit}."
        expect(@client2.output).to include "You played the #{card_kh.rank} of #{card_kh.suit}, the #{card_ks.rank} of #{card_ks.suit} and the #{card_2c.rank} of #{card_2c.suit}. Your opponent played the #{card_as.rank} of #{card_as.suit}, the #{card_js.rank} of #{card_js.suit} and the #{card_ad.rank} of #{card_ad.suit}."
      end
    end

    describe '#congratulate_round' do
      it 'congratulates only the winner' do
        @server.congratulate_round(match: @match, winner: game.player1)
        expect(@client.output).to include "You won!"
        expect(@client2.output).not_to include "You won!"
      end
      it 'condolences only the loser' do
        @server.congratulate_round(match: @match, winner: game.player2)
        expect(@client.output).to include "You lost!"
        expect(@client2.output).not_to include "You lost!"
      end
    end
  end
end
=begin
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
=end
