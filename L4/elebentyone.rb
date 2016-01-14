# elebentye game
# Pete Hanson

require 'pry'

STAKES = 500
BET = 100
MUST_STAY = 17
BUST = 21

def adjust_stakes!(state)
  player = final_score(state, :player) || 0
  dealer = final_score(state, :dealer) || 0
  if dealer > player
    transfer_money! state, :player, :dealer, BET
  elsif player > dealer
    transfer_money! state, :dealer, :player, BET
  end
end

def busted?(state, hand)
  get_scores(state, hand) == [0]
end

def cards_and_possible_scores(state, hand, n_drop)
  n_keep = state[:hands][hand].size - n_drop
  [cards_for_hand(state, hand, n_keep), possible_scores(state, hand, n_keep)]
end

def cards_for_hand(state, hand, n_keep)
  state[:hands][hand].take(n_keep).map { |card| card[:face] }.join ' '
end

def deal!(state)
  2.times { state[:hands].values.map! { |hand| hit! state, hand } }
end

def dealer_shows(state, hand, n_drop)
  cards, scores = cards_and_possible_scores state, hand, n_drop
  puts "The dealer shows <#{cards}> #{points_or_bust scores}"
end

# true -> hit, false -> stay
def dealer_turn?(state)
  dealer_scores = get_scores state, :dealer

  case dealer_scores.count { |score| score >= state[:stay] }
  when dealer_scores.size # must stay
    false
  when 0 # must hit
    true
  else # stay if we can beat or tie player, else pass
    player_score = final_score state, :player
    !dealer_scores.any? { |score| score >= player_score }
  end
end

def final_score(state, hand)
  get_scores(state, hand).max
end

# returns [0] if no cards have been dealt
def get_scores(state, hand)
  binding.pry
  the_hand = state[:hands][hand]
  the_hand.empty? ? [0] : the_hand.last[:scores]
end

def hit!(state, hand)
  face, values = state[:deck].pop
  prev_scores = get_scores state, hand
  scores = values.each_with_object([]) do |score, list|
    prev_scores.each do |prev_score|
      total = score + prev_score
      list.push total if total <= state[:bust]
    end
  end
  hand << { face: face, scores: scores.uniq }
end

def join_or(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + " #{final} #{list.last}"
end

def new_deck
  rank = (2..10).map { |face| [face, [face]] }
  rank << [:J, [10]] << [:Q, [10]] << [:K, [10]] << [:A, [1, 11]]
  (rank * 4).shuffle
end

def play!(state)
  puts "You have $#{state[:stakes][:player]} remaining."
  play_for_player! state
  play_for_dealer! state unless busted? state, :player
end

def play_for_dealer!(state)
  dealer_shows state, 0
  loop do
    break unless dealer_turn? state
    puts
    hit! state, hand
    dealer_shows state, 0
    sleep 2
    return if busted? state, :dealer
  end

  puts '', "Dealer has stayed at #{final_score state, hand} points.", ''
end

def play_for_player!(state)
  loop do
    you_have state
    dealer_shows state, 1
    return if busted? state, :player
    break unless player_turn?
    hit! state, :player
  end
  puts "You have stayed at #{final_score state, hand} points.", ''
end

def player_turn?
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

def points_or_bust(state, hand)
  scores = get_scores state, hand
  scores.empty? ? 'which is a bust.' : "for #{scores} points."
end

def possible_scores(state, hand, n_keep)
  get_scores(state, hand).take n_keep
end

def report_results(state)
  player = final_score state, :player
  dealer = final_score state, :dealer
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

def solicit_bust_value
  loop do
    puts "What score should each hand play to? (default: #{BUST})"
    print '> '
    answer = to_integer(gets.chomp, BUST, 3, 999)
    return answer if answer
    puts 'Please enter a value between 3 and 999, inclusive.'
  end
end

def solicit_stay_value(bust)
  loop do
    stay = bust - 4
    puts "At what score should the dealer be required to stay? " \
         "(default: #{stay})"
    print '> '
    answer = to_integer(gets.chomp, stay, bust - 9, bust - 1)
    return answer if answer
    puts "Please enter a value between #{bust - 9} and #{bust - 1}, inclusive."
  end
end

def to_integer(value, default, min, max)
  return default if value.empty?
  result = Integer(value)
  result if result >= min && result <= max
rescue ArgumentError
  nil
end

def transfer_money!(state, from_hand, to_hand, amount)
  state[:stakes][from_hand] -= amount
  state[:stakes][to_hand] += amount
end

def you_have(state)
  cards, scores = cards_and_possible_scores state, :player, 0
  puts "You have been dealt <#{cards}> #{points_or_bust scores}"
end

system 'clear'
puts <<-EOS
Welcome to Elebenty-1!

This game is similar to blackjack, but it lacks double-downs, 5 card charlies,
and splits. It also allows the player to set the target score and the score at
which the dealer must stay.

Each hand is a $#{BET} bet, and your stake (as well as the house's stake) is
$#{STAKES}. The first player to accumulate all of the available money wins.

EOS

# A card is a 2-element list. Element 0 is the face value of the card. Element
# 1 is a list of possible scores for the card. We don't bother with suits since
# they are unimportant in this game. A deck is a 52 element shuffled list of
# cards. Each hand begins with a fresh deck.
#
# A hand is list of hashes. Each element of the list represents one dealt card,
# with the first card dealt at [0]. Each hash member has the following data:
#
# [:face]    Face value for card (2-10, :J, :Q, :K, :A)
# [:scores]  A list of possible scores for this card plus all cards previously
#            dealt to this hand. A busted hand is represented by an empty list.
#
# The state hash info:
#
# [:deck]    The card deck
# [:hands]   The two card hands
#    [:player]   The player's hand
#    [:dealer]   The dealer's hand
# [:stakes]  The amount of money each player has
#    [:player]   The player's money
#    [:dealer]   The dealer's money
# [:target]  The target score (e.g., 21)
# [:stay]    The score at which the dealer must stay (e.g., 17)

state = {}
state[:bust] = solicit_bust_value
state[:stay] = solicit_stay_value state[:bust]
state[:stakes] = {
  player: STAKES,
  dealer: STAKES
}

loop do
  state[:deck] = new_deck
  state[:hands] = { player: [], dealer: [] }
  deal! state
  play! state
  adjust_stakes! state
  report_results state
  if state[:stakes][:player] <= 0
    puts "Sorry. You are out of money. Come back later."
    exit 0
  elsif state[:stakes][:dealer] <= 0
    puts "You've won the house limit. Please come again another time."
    exit 0
  else
    puts 'Starting next hand...', '', '', ''
    sleep 3
    system 'clear'
  end
end
