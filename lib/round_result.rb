class RoundResult

  attr_accessor :winner, :loser, :winner_cards, :loser_cards

  def initialize(winner:, loser:, cards: Hash.new([]) )
    @winner = winner
    @loser = loser
    @winner_cards = cards[winner]
    @loser_cards = cards[loser]
  end

  def num_war_sets
    winner_cards.length / 2
  end
end
