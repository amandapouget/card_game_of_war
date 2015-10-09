class Deck
  attr_reader :cards

  def initialize
    @cards = []
    ranks = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
    suits = ["clubs", "diamonds", "hearts", "spades"]
    ranks.each do |rank|
      suits.each do |suit|
        @cards << Card.new(rank: rank, suit: suit)
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def count_cards
    @cards.length
  end

  def deal_next_card
    @cards.shift
  end

  def empty?
    return count_cards==0
  end

  def add_card(card)
    @cards.push(card)
  end
end
