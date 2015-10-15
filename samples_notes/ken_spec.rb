require_relative '../war_server'

class MockWarClient


end

class WarServer #put in require_relative file
  def accept_new_client
    Thread.start(@server.accept) do |client|
      client.puts "Welcome!"
    end
  end
end

describe WarServer do
  it 'it is not listening on a default port when it is created' do
    server = WarServer.new
    begin
      client = MockWarClient.new
      expect()
    rescue => e
      puts e.message
      expect(e.message).to match(/spocket/i)
    end
  end
end
