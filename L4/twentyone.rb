# 21 game
# Pete Hanson

MUST_STAY = 17

def busted(data, hand)
  data[hand].last[:scores].empty?
end

def cards_and_possible_scores(data, hand, nkeep)
  [cards_for_hand(data, hand, nkeep), possible_scores(data, hand, nkeep)]
end

def cards_for_hand(data, hand, nkeep)
  data[hand].take(nkeep).map { |card| card[:face] }.join ' '
end

def deal!(data)
  [:player, :dealer].each { |hand| 2.times { hit! data, hand } }
end

def dealer_shows(data, n_drop)
  n_keep = data[:dealer].size - n_drop
  cards, scores = cards_and_possible_scores data, :dealer, n_keep
  puts "The dealer shows <#{cards}> #{points_or_bust scores}"
end

def dealer_turn(data)
  dealer_scores = data[:dealer].last[:scores]
  player_score = final_score(data, :player)
  must_stay_count = dealer_scores.count { |score| score >= MUST_STAY }
  puts
  return false if must_stay_count == dealer_scores.size
  return true if must_stay_count == 0
  !dealer_scores.any? { |score| score > player_score }
end

def final_score(data, hand)
  data[hand].last[:scores].max
end

def hit!(data, hand)
  face, values = data[:deck].pop
  prev_scores = data[hand].empty? ? [0] : data[hand].last[:scores]
  scores = values.each_with_object([]) do |score, list|
    prev_scores.each do |prev_score|
      total = score + prev_score
      list.push total if total <= 21
    end
  end
  data[hand] << { face: face, scores: scores.uniq }
end

def initialize_deck
  rank = (2..10).map { |face| [face, [face]] }
  rank << [:J, [10]] << [:Q, [10]] << [:K, [10]] << [:A, [1, 11]]
  (rank * 4).shuffle
end

def joinor(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + " #{final} #{list.last}"
end

def play!(data)
  play_for_player!(data)
  play_for_dealer!(data) unless busted data, :player
end

def play_for_dealer!(data)
  loop do
    dealer_shows data, 0
    break unless dealer_turn data
    hit! data, :player
    return if busted data, :player
  end

  puts "Dealer has stayed at #{final_score data, :dealer} points.", ''
end

def play_for_player!(data)
  loop do
    you_have data
    dealer_shows data, 1
    return if busted data, :player
    break unless player_turn
    hit! data, :player
  end
  puts "You have stayed at #{final_score data, :player} points.", ''
end

def player_turn
  puts "Hit (H) or Stay (S)?"
  loop do
    print '> '
    answer = gets.chomp.downcase
    puts
    return true if answer.start_with? 'h'
    return false if answer.start_with? 's'
    puts 'Invalid response. Please type H to hit, or S to stay.'
  end
end

def points_or_bust(scores)
  scores.empty? ? 'which is a bust.' : "for #{scores} points."
end

def possible_scores(data, hand, nkeep)
  joinor(data[hand].take(nkeep).last[:scores])
end

def report_results(data)
  player = final_score(data, :player)
  dealer = final_score(data, :dealer)
  if player.nil?
    puts 'You busted. Dealer wins!'
  elsif dealer.nil?
    puts 'Dealer busted. You win!'
  elsif player > dealer
    puts "You won #{player}-#{dealer}"
  elsif dealer > player
    puts "Dealer won #{dealer}-#{player}"
  else
    puts "Tie game: #{player}-#{dealer}"
  end
end

def you_have(data)
  cards, scores = cards_and_possible_scores data, :player, data[:player].size
  puts "You have been dealt <#{cards}> #{points_or_bust scores}"
end

# A card is a 2-element list. Element 0 is the face value of the card. Element
# 1 is a list of possible scores for the card. We don't bother keep track of
# suits since they are unimportant in 21.
#
# The data structure used to track and manage the game is organized as follows.
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
play! data
report_results data
