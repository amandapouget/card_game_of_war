require './lib/match.rb'

class User
  @@users = []
  attr_accessor :id, :matches, :current_match, :name, :client

  def initialize(name: "Anonymous", client: nil)
    @client = client
    @name = name
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

  def self.all
    @@users
  end

  def self.clear
    @@users = []
  end
end

class NullUser
  attr_accessor :id, :matches, :current_match, :name, :client

  def initialize
    @current_match = NullMatch.new
    @matches = []
  end

  def end_current_match
  end

  def self.find(id)
    NullUser.new
  end

  def save
  end

  def add_match(match)
  end

  def self.all
    []
  end

  def self.clear
  end

  def ==(nulluser)
    nulluser.is_a? NullUser
  end
end
