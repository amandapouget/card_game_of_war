require 'socket'
require 'json'
require_relative './game'
require_relative './player'
require './lib/user.rb'
require 'pry'
require 'timeout'

class WarServer
  attr_accessor :port, :socket, :pending_clients, :clients, :game

  def initialize(port: 2000)
    @port = port
  end

  def start
    @socket = TCPServer.open('localhost', @port)
    @pending_clients = []
    @clients = []
  end

  def make_threads # not tested
    until @socket.closed? do
      Thread.start(accept) { |client| run(client) }
    end
  end

  def accept
    client = @socket.accept
    @pending_clients << client
    send_output(client, "Welcome to war! I will connect you with your partner...")
    client
  end

  def run(client) # NOT TESTED
    puts "RUNNING"
    user = match_user(client, get_id(client))
    puts !user.current_match.game.game_over?
    if !user.current_match.game.game_over?
      @pending_clients.each { |client| @pending_clients.delete(client) if user.client == client }
      @clients << user.client
    elsif pair_players
      client1 = @clients.last
      client2 = @clients[@clients.length-2]
      match = make_match(user1, user2)
      match.game.deal
      puts "DEALT A GAME!"
      play_match(match)
      [client1, client2].each { |client| stop_connection(client) }
    end
  end

  def get_input(client)
    begin
      client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
    rescue IOError
      return "client unavailable"
    end
  end

  def send_output(client, output)
    client.puts(output)
  rescue IOError
  end

  def get_id(client)
    send_output(client, "Please enter your unique id or hit enter to create a new user.")
    id = get_input(client).to_i
    Thread.kill if id == "client unavailable"
  end

  def match_user(client, id)
    user = User.find(id)
    if user
      send_output(client, "Welcome back #{user.name}! Hit enter to play!")
      input = get_input(client)
      Thread.kill if input == "client unavailable"
    else
      user = User.new(name: get_name(client))
    end
    user.client = client
    user
  end

  def get_name(client)
    send_output(client, "What is your name?")
    name = get_input(client)
    Thread.kill if name == "client unavailable"
    name
  end

  def pair_players
    2.times { @clients << @pending_clients.shift } if @pending_clients.length == 2
  end

  def make_match(user1, user2)
    player1 = Player.new(name: user1.name)
    player2 = Player.new(name: user2.name)
    game = Game.new(player1: player1, player2: player2)
    match = Match.new(game: game, user1: user1, user2: user2)
    [user1, user2].each { |user| user.current_match = match }
    match
  end

  def play_match(match)
    while !match.game.game_over?
      tell_match(match)
        match.users.each do |user|
          input = get_input(user.client)
          if input == "client unavailable"
            Timeout::timeout(30) { input = get_input(user.client) until !(input == "client unavailable") }
          end
        end
      round_result = match.game.play_round
      tell_round(match, round_result)
    end
    tell_match(match)
  end

  def tell_match(match)
    match_info = JSON.dump(match.to_json)
    match.users.each { |user| send_output(user.client, match_info) }
  end

  def tell_round(match, round_result)
    round_info = JSON.dump(round_result.to_json)
    match.users.each { |user| send_output(user.client, round_info) }
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
