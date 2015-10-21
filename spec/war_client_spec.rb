require 'spec_helper'

describe WarClient do
  let(:client) { WarClient.new }
  let(:server) { WarServer.new }

  def capture_stdout(&blk)
    old = $stdout
    $stdout = fake = StringIO.new
    blk.call
    fake.string
  ensure
    $stdout = old
  end

  it 'does nothing when initialized' do
    expect { client }.to_not raise_exception
  end

  it '#start tries to connect to the server, with new socket attribute' do
    begin
      client.start
    rescue => e
      expect(e.message).to match(/connection refused/i)
    end
  end

  context 'server and client started, connection accepted,' do
    before do
      server.start
      client.start
      server.accept
    end

    after do
      server.stop_server
    end

    it '#start when it successfully connects, gets a welcome message back from the server' do
      expect { client.socket.read_nonblock(1000) }.to_not raise_exception
    end

    it 'puts the welcome message to the client' do
      putted = capture_stdout { client.puts_welcome }
      expect(putted).to match /.+/
    end
  end
end






=begin
describe '#tell_starting_state' do
end

describe '#tell_ending_state' do
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

describe '#congratulate_game' do
  it 'congratulates only the game winner' do
    @server.congratulate_game(match: @match, winner: game.player1)
    expect(@client.output).to include "You won the game!"
    expect(@client2.output).not_to include "You won the game!"
  end
  it 'condolences only the game loser' do
    @server.congratulate_game(match: @match, winner: game.player2)
    expect(@client.output).to include "You lost the game!"
    expect(@client2.output).not_to include "You lost the game!"
  end
end
=end
