require 'round_result'
require 'player'
require 'card'

describe RoundResult do
  let(:player1) { Player.new(name: "Amanda") }
  let(:player2) { Player.new(name: "Vianney") }
  let(:card_2c) { Card.new(rank: "two", suit: "clubs") }
  let(:card_7h) { Card.new(rank: 'seven', suit: 'hearts') }
  let(:card_jh) { Card.new(rank: "jack", suit: "hearts") }
  let(:card_ks) { Card.new(rank: "king", suit: "spades") }
  let(:card_kh) { Card.new(rank: "king", suit: "hearts") }
  let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
  let(:war_result) { RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh, card_jh, card_7h], player2 => [card_ks, card_ad, card_2c] }) }
  let(:reg_result) { RoundResult.new(winner: player1, loser: player2, cards: { player1 => [card_kh], player2 => [card_7h] }) }
  let(:cardless_result) { RoundResult.new(winner: player1, loser: player2) }

  it 'initializes with key information about a round: who played what and when and who won' do
    expect(reg_result.winner).to eq player1
    expect(reg_result.loser).to eq player2
    expect(reg_result.winner_cards).to eq [card_kh]
    expect(reg_result.loser_cards).to eq [card_7h]
  end

  it 'still initializes when given no cards' do
    expect(cardless_result.winner).to eq player1
    expect(cardless_result.loser).to eq player2
    expect(cardless_result.winner_cards).to eq []
    expect(cardless_result.loser_cards).to eq []
  end

  describe '#num_war_sets' do
    it 'calculates how many war sets were played this round' do
      expect(reg_result.num_war_sets).to eq 0
    end

    it 'works with a war set' do
      expect(war_result.num_war_sets).to eq 1
    end
  end

  describe '#to_json' do
    it 'turns its information into a json-worthy hash' do
      json_hash = {
        winner: "Amanda",
        loser: "Vianney",
        winner_cards: ["king of hearts", "jack of hearts", "seven of hearts"],
        loser_cards: ["king of spades", "ace of diamonds", "two of clubs"],
        num_war_sets: 1
      }
      expect(war_result.to_json).to eq json_hash
    end

    it 'works when the round had no cards' do
      json_hash = {
        winner: "Amanda",
        loser: "Vianney",
        winner_cards: [],
        loser_cards: [],
        num_war_sets: 0
      }
      expect(cardless_result.to_json).to eq json_hash
    end
  end
end
