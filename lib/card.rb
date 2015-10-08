class Card

  def initialize(attributes)
    @rank = attributes[:rank]
    @suit = attributes[:suit]
    @face_up = true
  end

  def face_up
    @face_up
  end

  def rank
    @rank unless !face_up
  end

  def suit
    @suit unless !face_up
  end

  def rank_numeric_value
    card_values = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
    return card_values.index(@rank) + 2 unless !face_up
  end

  def turn_over
    @face_up = !@face_up
  end
end
