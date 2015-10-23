require 'socket'
require 'json'
require_relative './game'
require_relative './player'
require './lib/user.rb'
require 'pry'
require 'timeout'

class WarServer
  attr_accessor :port, :socket, :pending_users, :clients, :game

  def initialize(port: 2000)
    @port = port
  end

  def start
    @socket = TCPServer.open('localhost', @port)
    @pending_users = []
    @clients = []
  end

  def make_threads # not tested
    until @socket.closed? do
      Thread.start(accept) { |client| run(client) }
    end
  end

  def accept
    client = @socket.accept
    @clients << client
    send_output(client, "Welcome to war! I will connect you with your partner...")
    client
  end

  def run(client) # NOT TESTED
    user = match_user(client, get_id(client))
    @pending_users << user unless user.match_in_progress?
    if player_pair_ready?
      opponent = @pending_users.shift
      user = @pending_users.shift
      match = make_match(user, opponent)
      ask_to_start_match(match)
      match.game.deal
      play_match(match)
      match.users.each { |user| stop_connection(user.client) }
    end
  end

  def player_pair_ready?
    @pending_users.length >= 2
  end

  def get_id(client)
    send_output(client, "Please enter your unique id or hit enter to create a new user.")
    get_input(client).to_i || die
  end

  def get_name(client)
    send_output(client, "What is your name?")
    get_input(client) || die # add time-out for unresponsive user?
  end

  def get_input(client)
    begin
      client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
      retry
    rescue IOError
      return nil
    end
  end

  def send_output(client, output)
    client.puts(output)
  rescue IOError
  end

  def die(client) # NOT TESTED
    stop_connection(client)
    Thread.kill(Thread.current)
  end

  def match_user(client, id)
    user = User.find(id)
    if user
      send_output(client, "Welcome back #{user.name}!")
    else
      user = User.new(name: get_name(client))
      send_output(client, "Your unique id is #{user.object_id}. Don't lose it! You'll need it to log in again as you play.")
    end
    user.client = client
    user
  end

  def ask_to_start_match(match)
    match.users.each { |user| send_output(user.client, "Hit enter to play!") }
    match.users.each { |user| get_input_or_end_match(30, match, user) }
  end

  def make_match(user1, user2)
    player1 = Player.new(name: user1.name)
    player2 = Player.new(name: user2.name)
    game = Game.new(player1: player1, player2: player2)
    match = Match.new(game: game, user1: user1, user2: user2)
    match
  end

  def play_match(match, timeout_sec = 30)
    while !match.game.game_over?
      tell_match(match)
      match.users.each { |user| get_input_or_end_match(timeout_sec, match, user) }
      round_result = match.game.play_round
      tell_round(match, round_result)
    end
    tell_match(match)
    match.end_match
  end

  def get_input_or_end_match(timeout_sec, match, user)
    input = nil
    begin
      Timeout::timeout(timeout_sec) { input = get_input(user.client) until input }
    rescue
      match.users.each do |user|
        send_output(user.client, "Game forfeited!")
        stop_connection(user.client)
      end
      match.end_match
      Thread.kill(Thread.current) unless timeout_sec = 0.1 # moment of cheating... can't have it kill RSPEC thread!
    end
    input if input
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
    client.close unless client.closed?
    @clients.delete(client)
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client } if @clients
    connections.each { |client| stop_connection(client) }
    @pending_users = [] if @pending_users
    @socket.close if (@socket && !@socket.closed?)
  end
end
