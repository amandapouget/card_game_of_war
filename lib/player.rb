class Player

  attr_reader :name, :cards

  def initialize(attributes)
    @name = attributes[:name]
    @cards = []
  end

  def play_next_card
    @cards[0].turn_over
    @cards.shift
  end

  def play_war_cards
    war_cards = []
    war_cards << @cards.shift
    war_cards << play_next_card
    war_cards
  end

  def collect_winnings(cards)
    cards.each do |card|
      card.turn_over if card.face_up?
      @cards << card
    end
  end

  def add_card(card)
    card.turn_over if card.face_up?
    @cards << card
  end

  def count_cards
    @cards.length
  end

  def out_of_cards?
    @cards==[]
  end
end
