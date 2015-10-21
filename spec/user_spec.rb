require 'spec_helper'

describe User do
  let(:user) { User.new() }
  let(:user2) { User.new() }
  let(:match) { Match.new() }
  let(:match2) { Match.new() }

  it 'has a unique id' do
    expect(user.id).to eq user.object_id
    expect(user.id == user2.id).to be false
  end

  it 'returns the right user when given just an id' do
    id = user.id
    expect(User.find(id)).to eq user
  end

  it 'knows what matches it has played but does not allow duplicates' do
    user.add_match(match)
    user.add_match(match)
    user.add_match(match2)
    expect(user.matches).to match_array [match, match2]
  end

  it 'knows if a match is currently in session and which one' do
    user.current_match = match
    expect(user.current_match).to eq match
  end

  it 'ends a match by replacing the current_match with a nullmatch' do
    user.add_match(match)
    user.end_current_match
    expect(user.current_match).to be_a NullMatch
  end
end
