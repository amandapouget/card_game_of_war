require './lib/war_server.rb'

server = WarServer.new()
server.start
server.make_threads
