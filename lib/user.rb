require './lib/match.rb'

class User
  @@users = []
  attr_accessor :id, :matches, :current_match

  def initialize
    @id = self.object_id
    @matches = []
    @current_match = NullMatch.new
    save(self)
  end

  def save(user)
    @@users << user
    @@users.uniq!
  end

  def self.find(id)
    @@users.each { |user| return user if user.id == id }
    return nil
  end

  def add_match(match)
    @current_match = match
    @matches << match
    @matches.uniq!
  end

  def end_current_match
    @current_match = NullMatch.new
  end
end
