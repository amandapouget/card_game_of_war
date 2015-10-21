require 'spec_helper'

describe Match do
  let(:game) { Game.new(player1: Player.new(name: "Amanda"), player2: Player.new(name:"Vianney")) }
  let(:my_match) { Match.new(game: game, client1: MockWarClient.new, client2: MockWarClient.new) } # I don't like that I use a client object here instead of a socket as would happen in a real use case

  it 'initializes with a game and two clients, plus two players discerned from the game' do
    expect(my_match.game).to be_a Game
    expect(my_match.client1).to be_truthy
    expect(my_match.client2).to be_truthy
    expect(my_match.player1).to eq my_match.game.player1
    expect(my_match.player2).to eq my_match.game.player2
  end

  it 'can give you an array of its clients' do
    expect(my_match.clients[0]).to eq my_match.client1
    expect(my_match.clients[1]).to eq my_match.client2
  end

  it 'can tell you which player is matched to one of its clients' do
    client = my_match.client1
    expect(my_match.player(client)).to eq my_match.player1
    client2 = my_match.client2
    expect(my_match.player(client2)).to eq my_match.player2
  end

  it 'can tell you which client is matched to one of its players' do
    player1 = my_match.player1
    expect(my_match.client(player1)).to eq my_match.client1
    player2 = my_match.player2
    expect(my_match.client(player2)).to eq my_match.client2
  end

  it 'can give you a json-worthy hash containing the most critical information about the objects it contains' do
    game.winner = game.player1
    game.loser = game.player2
    json_hash = {
      player1: "Amanda",
      player2: "Vianney",
      player1_cards: 0,
      player2_cards: 0,
      winner: "Amanda",
      loser: "Vianney",
      rounds_played: 0
    }
    expect(my_match.to_json).to eq json_hash
  end
end
