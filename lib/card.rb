class Card

  def initialize(attributes)
    @rank = attributes[:rank]
    @suit = attributes[:suit]
    @face_up = false # Amanda gets to find out why states are evil today!
  end

  def face_up?
    @face_up
  end

  def rank
    @rank unless !face_up?
  end

  def suit
    @suit unless !face_up?
  end

  def rank_numeric_value # change to rank_value
    card_values = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
    return card_values.index(@rank) + 2 unless !face_up?
  end

  def turn_over # this is something that belongs in the user interface not the state of the card itself
    @face_up = !face_up?
  end

  def ==(another_card)
    return false if !face_up? || !another_card.face_up? # Here's a great example of why states are evil!
    return @rank == (another_card.rank) && @suit == (another_card.suit)
  end
end
