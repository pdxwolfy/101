# 21 game
# Pete Hanson

def cards_and_score_for_hand(data, hand)
  [cards_for_hand(data, hand), score_for_hand(data, hand)]
end

def cards_for_hand(data, hand)
  data[hand].map { |card| card[:face] }.join ' '
end

def deal!(data)
  [:player, :dealer].each { |hand| 2.times { deal_card! data, hand } }
end

def deal_card!(data, hand)
  face, values = data[:deck].pop
  prev_scores = data[hand].empty? ? [0] : data[hand].last[:scores]
  scores = []
  values.each do |score|
    prev_scores.each do |prev_score|
      total = score + prev_score
      scores.push total if total <= 21
    end
  end
  data[hand] << { face: face, scores: scores.uniq }
end

def dealer_shows(data)
  cards, scores = cards_and_score_for_hand data, :dealer
  puts "The dealer shows <#{cards}> for #{scores} points."
end

def initialize_deck
  rank = (2..10).map { |face| [face, [face]] }
  rank << [:J, [10]] << [:Q, [10]] << [:K, [10]] << [:A, [1, 11]]
  (rank * 4).shuffle
end

def joinor(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + "#{sep}#{final} #{list.last}"
end

def score_for_hand(data, hand)
  joinor(data[hand].map { |card| card[:scores] })
end

def you_have(data)
  cards, scores = cards_and_score_for_hand data, :player
  puts "You have been dealt <#{cards}> for #{scores} points."
end

# A card is a 2-element list. Element 0 is the face value of the card. Element
# 1 is a list of possible scores for the card.
#
# data[:deck]            Deck of undealt cards (randomized list of face values)
# data[:player]          Data for player
#   [i]                  ...for card #i
#      [:face]           ......card face value
#      [:scores]         ......possible total scores for cards 0->i (no busts)
# data[:dealer]          Data for dealer
#   [j]                  ...for card #j
#      [:face]           ......card face value
#      [:scores]         ......possible total scores for cards 0->j (no busts)
data = {
  deck:   initialize_deck,
  player: [],
  dealer: []
}

deal! data
you_have data
dealer_shows data

while player_turn data
  player_hit! data
  if player_bust data
    dealer_wins data
    exit 0
  end
end

while dealer_turn data
  dealer_hit! data
  if dealer_bust data
    player_wins data
    exit 0
  end
end


p data
