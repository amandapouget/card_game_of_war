class Player

  attr_reader :name, :cards

  def initialize(name: "Anonymous")
    @name = name
    @cards = []
  end

  def play_next_card
    return if out_of_cards?
    @cards.shift
  end

  def collect_winnings(cards)
    cards.each do |card|
      add_card(card)
    end
  end

  def add_card(card)
    @cards << card
  end

  def count_cards
    @cards.length
  end

  def out_of_cards?
    @cards==[]
  end
end

class NullPlayer < Player
  attr_accessor :name, :cards

  def initialize
    @name = nil
    @cards = []
  end

  def play_next_card
  end

  def collect_winnings
  end

  def add_card
  end

  def ==(player)
    player.is_a? NullPlayer
  end
end
