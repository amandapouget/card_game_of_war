require 'round_result'
require 'player'
require 'card'

describe RoundResult do
  let(:player1) { Player.new(name: "Amanda") }
  let(:player2) { Player.new(name: "Vianney") }
  let(:card_2c) { Card.new(rank: "two", suit: "clubs") }
  let(:card_3c) { Card.new(rank: "three", suit: "clubs") }
  let(:card_7s) { Card.new(rank: 'seven', suit: 'spades') }
  let(:card_7h) { Card.new(rank: 'seven', suit: 'hearts') }
  let(:card_jh) { Card.new(rank: "jack", suit: "hearts") }
  let(:card_js) { Card.new(rank: "jack", suit: "spades") }
  let(:card_ks) { Card.new(rank: "king", suit: "spades") }
  let(:card_kh) { Card.new(rank: "king", suit: "hearts") }
  let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
  let(:card_ah) { Card.new(rank: 'ace', suit: 'hearts') }

  it 'initializes with key information about a round: who played what and when and who won' do
    my_round_result = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh], player2 => [card_7s] } )
    expect(my_round_result.winner).to eq player1
    expect(my_round_result.loser).to eq player2
    expect(my_round_result.winner_cards).to eq [card_kh]
    expect(my_round_result.loser_cards).to eq [card_7s]
  end

  it 'works when given no cards' do
    my_round_result = RoundResult.new(winner: player1, loser: player2)
    expect(my_round_result.winner).to eq player1
    expect(my_round_result.loser).to eq player2
    expect(my_round_result.winner_cards).to eq []
    expect(my_round_result.loser_cards).to eq []
  end

  it 'calculates how many war sets were played this round' do
    my_round_result = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh], player2 => [card_7s] } )
    expect(my_round_result.num_war_sets).to eq 0
  end

  it 'works with a war set' do
    my_round_result = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_jh, card_7h, card_ah, card_3c], player2 => [card_ks, card_ad, card_7s, card_js, card_2c] } )
    expect(my_round_result.num_war_sets).to eq 2
  end

  it 'works when someone runs out of cards mid-round' do
    result_1_0 = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh], player2 => [] } )
    result_3_1 = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_ah, card_ad], player2 => [card_ks] } )
    result_3_2 = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_ah, card_ad], player2 => [card_ks, card_7s] } )
    result_5_3 = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_jh, card_ad, card_7h, card_2c], player2 => [card_ks, card_7s, card_ah] } )
    result_5_4 = RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_jh, card_ad, card_7h, card_2c], player2 => [card_ks, card_7s, card_ah, card_3c] } )
    expect(result_1_0.num_war_sets).to eq 0
    expect(result_3_1.num_war_sets).to eq 1
    expect(result_3_2.num_war_sets).to eq 1
    expect(result_5_3.num_war_sets).to eq 2
    expect(result_5_4.num_war_sets).to eq 2
  end
end
