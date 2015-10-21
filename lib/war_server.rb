require 'socket'
require 'json'
require_relative './game'
require_relative './player'
require './lib/user.rb'
require 'pry'

class WarServer
  attr_accessor :port, :socket, :pending_clients, :clients, :game

  def initialize(port: 2000)
    @port = port
  end

  def start
    @socket = TCPServer.open('localhost', @port)
    @pending_clients = []
    @clients = []
    @pending_users = []
  end

  def make_threads # not tested
    until @socket.closed? do
      Thread.start(accept) { |client| run(client) }
    end
  end

  def accept
    client = @socket.accept
    @pending_clients << client
    client.puts "Welcome to war! I will connect you with your partner..."
    client
  end

  def run(client) # NOT TESTED
    id = get_id(client)
    user = match_user(client, id)
    if !user.current_match.game.game_over?
      reconnect(user)
    elsif pair_players
      client1 = @clients.last
      client2 = @clients[@clients.length-2]
      match = make_game(user1, user2)
      play_game(match)
      [client1, client2].each { |client| stop_connection(client) }
    end
  end

  def reconnect(user)
    @pending_users << user
    @pending_clients.each { |client| @pending_clients.delete(client) if user.client == client }
    @clients << user.client
  end

  def get_id(client)
    client.puts "Please enter your unique id or hit enter to create a new user."
    id = get_input(client).to_i
  end

  def match_user(client, id)
    user = User.find(id)
    if user
      client.puts "Welcome back #{user.name}! Hit enter to play!"
      get_input(client)
    else
      user = User.new(name: get_name(client))
    end
    user.client = client
    user
  end

  def get_name(client)
    client.puts "What is your name?"
    get_input(client)
  end

  def get_input(client)
    begin
      client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
    rescue IOError
      return IOError
    end
  end

  def pair_players
    2.times { @clients << @pending_clients.shift } if @pending_clients.length == 2
  end

  def make_game(user1, user2)
    player1 = Player.new(name: user1.name)
    player2 = Player.new(name: user2.name)
    game = Game.new(player1: player1, player2: player2)
    game.deal
    Match.new(game: game, user1: user1, user2: user2)
  end

  def play_game(match)
    while !match.game.game_over?
      tell_match(match)
      match.users.each { |user|
        input = get_input(user.client)
        if input.is_a? IOError
          find_client(user)
        end
      }
      round_result = match.game.play_round
      tell_round(match, round_result)
    end
    tell_match(match)
  end

  def find_client(user)
    found = false
    until found do
      # need a way to kill the whole thread if both players disconnect
      @pending_users.each do |pending_user|
        if pending_user == user
          user.client = pending_user.client
          user.client.puts "Hit enter to reconnect with your game."
          get_input(user.client)
          found = true
        end
      end
    end
  end

  def tell_match(match)
    match_info = JSON.dump(match.to_json)
    match.users.each { |user| user.client.puts(match_info) }
  end

  def tell_round(match, round_result)
    round_info = JSON.dump(round_result.to_json)
    match.users.each { |user| user.client.puts(round_info) }
  end

  def stop_connection(client)
    @clients.delete(client)
    @pending_clients.delete(client)
    client.close unless client.closed?
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client } if @clients
    @pending_clients.each { |client| connections << client } if @pending_clients
    connections.each { |client| stop_connection(client) }
    @socket.close if (@socket && !@socket.closed?)
  end
end
