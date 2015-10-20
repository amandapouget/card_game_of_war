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

  def to_json
    {
      winner: winner.name,
      loser: loser.name,
      winner_cards: cards_to_s(winner_cards),
      loser_cards: cards_to_s(loser_cards),
      num_war_sets: num_war_sets }
  end

  def cards_to_s(cards_array)
    string_array = []
    cards_array.each { |card| string_array << card.to_s }
    string_array
  end
end
