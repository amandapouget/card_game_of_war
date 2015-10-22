require './lib/war_client.rb'

@client = WarClient.new

@client.start

def over?
  @client.socket.closed?
end

until over? do
  @client.puts_message unless over? # still have the problem that it gets stuck on gets if the server doesn't give all at once all of its messages-before-next-gets ("Hit enter to play")
  input = gets.chomp unless over?
  sleep 0.1
  if input == "stop"
    @client.socket.close
  end
  if input !=nil
    @client.provide_input(input) unless over?
  end
end
