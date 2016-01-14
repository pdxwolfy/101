# 21 game
# Pete Hanson

STAKES = 500
BET = 100
MUST_STAY = 17

def adjust_stakes!(stakes, hands)
  player = final_score(hands[:player]) || 0
  dealer = final_score(hands[:dealer]) || 0
  if dealer > player
    stakes[:player] -= BET
    stakes[:dealer] += BET
  elsif player > dealer
    stakes[:player] += BET
    stakes[:dealer] -= BET
  end
end

def busted(hand)
  hand.last[:scores].empty?
end

def cards_and_possible_scores(hand, keep_count)
  [cards_for_hand(hand, keep_count), possible_scores(hand, keep_count)]
end

def cards_for_hand(hand, keep_count)
  hand.take(keep_count).map { |card| card[:rank] }.join ' '
end

def deal!(deck, hands)
  2.times { hands.values.map! { |hand| hit! deck, hand } }
end

def dealer_shows(hand, drop_count)
  cards, scores = cards_and_possible_scores(hand, hand.size - drop_count)
  puts "The dealer shows <#{cards}> #{points_or_bust scores}"
end

def dealer_turn(hand, player_hand)
  scores = hand.last[:scores]
  player_score = final_score(player_hand)
  must_stay_count = scores.count { |score| score >= MUST_STAY }
  puts
  return false if must_stay_count == scores.size
  return true if must_stay_count == 0
  !scores.any? { |score| score > player_score }
end

def final_score(hand)
  hand.last[:scores].max
end

def hit!(deck, hand)
  card = deck.pop
  prev_scores = hand.empty? ? [0] : hand.last[:scores]
  scores = card[:values].each_with_object([]) do |score, list|
    prev_scores.each do |prev_score|
      total = score + prev_score
      list.push total if total <= 21
    end
  end
  hand << { rank: card[:rank], scores: scores.uniq }
end

def joinor(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + " #{final} #{list.last}"
end

def new_deck
  deck = (2..10).map { |rank| { rank: rank, values: [rank] } }
  [:J, :Q, :K].each { |rank| deck << { rank: rank, values: [10] } }
  deck << { rank: :A, values: [1, 11] }
  (deck * 4).shuffle
end

def play!(deck, hands, stakes)
  player = hands[:player]
  dealer = hands[:dealer]
  puts "You have $#{stakes} remaining."
  play_for_player!(deck, player, dealer)
  play_for_dealer!(deck, dealer, player) unless busted player
end

def play_for_dealer!(deck, hand, player_hand)
  dealer_shows hand, 0
  loop do
    break unless dealer_turn hand, player_hand
    hit! deck, hand
    dealer_shows hand, 0
    sleep 2
    return if busted hand
  end

  puts "Dealer has stayed at #{final_score hand} points.", ''
end

def play_for_player!(deck, hand, dealer_hand)
  loop do
    you_have hand
    dealer_shows dealer_hand, 1
    return if busted hand
    break unless player_turn
    hit! deck, hand
  end
  puts "You have stayed at #{final_score hand} points.", ''
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

def possible_scores(hand, keep_count)
  joinor(hand.take(keep_count).last[:scores])
end

def report_results(hands)
  player = final_score hands[:player]
  dealer = final_score hands[:dealer]
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

def you_have(hand)
  cards, scores = cards_and_possible_scores hand, hand.size
  puts "You have been dealt <#{cards}> #{points_or_bust scores}"
end

system 'clear'
puts <<-EOS
Welcome to 21!

This game is similar to blackjack, but it lacks double-downs, 5 card charlies,
and splits. Each hand is a $#{BET} bet, and your stake (as well as the house's
stake) is $#{STAKES}. The first player to accumulate all of the available money wins.

EOS

# A card is a 2-element list. Element 0 is the rank value of the card. Element
# 1 is a list of possible scores for the card. We don't bother keep track of
# suits since they are unimportant in 21.
#
# A deck is a 52 element shuffled list of cards. Each hand begins with a fresh
# deck.
#
# A hand is list of hashes. Each element of the list represents one dealt card,
# with the first card dealt at [0]. Each hash member has the following data:
#    [:rank]    Rank value for card (2-10, :J, :Q, :K, :A)
#    [:scores]  A list of possible scores for this card plus all cards
#               previously deal t0 this hand. A busted hand has an empty list
#               in this field/

stakes = {
  player: STAKES,
  dealer: STAKES
}

loop do
  deck = new_deck
  hands = {
    player: [],
    dealer: []
  }

  deal! deck, hands
  play! deck, hands, stakes[:player]
  adjust_stakes! stakes, hands
  report_results hands
  if stakes[:player] == 0
    puts "Sorry. You are out of money. Come back later."
    exit 0
  elsif stakes[:dealer] == 0
    puts "You've won the house limit. Please come again another time."
    exit 0
  else
    puts 'Starting next hand...', '', '', ''
    sleep 3
    system 'clear'
  end
end
