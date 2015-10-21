class Match
  attr_accessor :game, :player1, :player2, :client1, :client2

  def initialize(game:, client1:, client2:)
    @game = game
    @client1 = client1
    @client2 = client2
    @player1 = game.player1
    @player2 = game.player2
  end

  def client(player)
    return @client1 if player == player1
    return @client2 if player == player2
  end

  def player(client)
    return @player1 if client == client1
    return @player2 if client == client2
  end

  def clients
    [@client1, @client2]
  end

  def to_json
    {
      player1: player1.name,
      player2: player2.name,
      player1_cards: player1.count_cards,
      player2_cards: player2.count_cards,
      winner: game.winner.name,
      loser: game.loser.name,
      rounds_played: game.rounds_played
    }
  end
end
