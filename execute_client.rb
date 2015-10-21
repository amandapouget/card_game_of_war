require './lib/war_client.rb'

client = WarClient.new
client.start
loop do
  client.puts_message
  client.provide_input(gets.chomp)
end

# you'll need a loop here that matches play_game in server, so that the client is outputting at the right moment and sending at the right moment
