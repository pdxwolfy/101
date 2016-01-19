# eleventye game
# Pete Hanson

require 'pry'

MAX_POINTS = 5
MUST_STAY = 17
BUST = 21

def busted?(state, who)
  state[who][:scores].empty?
end

def card(rank)
  values = case rank
           when (2..10)    then [rank]
           when :J, :Q, :K then [10]
           when :A         then [1, 11]
           end
  { rank: rank, values: values }
end

def cards_and_possible_scores(state, who)
  [cards_for_hand(state, who), possible_scores(state, who)]
end

def cards_for_hand(state, who)
  state[who][:hand].map { |a_card| a_card[:rank] }.join ' '
end

def compute_new_scores(state, who, new_card)
  scores = state[who][:scores].product(new_card[:values]).map do |the_scores|
    the_scores.inject(:+)
  end

  scores.select { |sum| sum <= state[:target] }.uniq
end

def deal!(state)
  [:player, :dealer, :player].each { |who| hit! state, who }
  state[:dealer][:down] = get_card_from_deck! state
end

def dealer_shows(state, has = 'has been dealt')
  cards, scores = cards_and_possible_scores state, :dealer
  puts "The dealer #{has} <#{cards}> #{points_or_bust scores}"
end

# true -> hit, false -> stay (or busted)
def dealer_turn?(state)
  return false if busted? state, :dealer

  dealer_scores = state[:dealer][:scores]
  hits, stays = dealer_scores.partition { |score| score < state[:target] - 4 }
  if hits.empty? # No hit scores
    false
  elsif stays.empty? # No stay scores
    true
  else # hit again only if best current score is a losing score
    stays.max < final_score(state, :player)
  end
end

def end_of_play_message(state, who)
  if busted? state, who
    'busted.'
  elsif max_score? state, who
    "#{state[:target]}!"
  else
    "stayed at #{final_score state, who} points."
  end
end

def final_score(state, who)
  state[who][:scores].max
end

def flip_dealer_card!(state)
  hit! state, :dealer, state[:dealer][:down]
end

def get_card_from_deck!(state)
  if state[:deck].empty?
    state[:deck] = new_deck
    puts '', '*** A new deck has been put into play. ***', ''
  end

  state[:deck].pop
end

def hit!(state, who, card = nil)
  the_card = card || get_card_from_deck!(state)
  state[who][:hand] << the_card
  state[who][:scores] = compute_new_scores state, who, the_card
end

def join_or(list, sep = ', ', final = 'or')
  if list.size <= 1 || final.empty?
    list.join sep # e.g., "3"
  elsif list.size == 2
    list.join " #{final} " # e.g., "3 or 5"
  else
    # e.g., "3, 4, or 6"
    list.take(list.size - 1).join(sep) + "#{sep}#{final} #{list.last}"
  end
end

def max_score?(state, who)
  final_score(state, who) == state[:target]
end

def new_deck
  ranks = (2..10).to_a + [:J, :Q, :K, :A]
  one_suit = ranks.map { |rank| card rank }
  (one_suit * 4).shuffle
end

def play!(state)
  player_wins = state[:player][:wins]
  dealer_wins = state[:dealer][:wins]
  puts "You have won #{player_wins} game#{plural player_wins}; " \
       "the dealer has won #{dealer_wins}."

  deal! state
  play_for_player! state
  puts "You have #{end_of_play_message state, :player}", ''
  unless busted? state, :player
    flip_dealer_card! state
    play_for_dealer! state
    puts '', "Dealer has #{end_of_play_message state, :dealer}", ''
  end

  report_results state
  record_win! state
end

def play_for_dealer!(state)
  dealer_shows state
  while dealer_turn? state
    hit! state, :dealer
    dealer_shows state
    sleep 2 if $stdout.isatty # conditional is for testing
    return if busted?(state, :dealer) || max_score?(state, :dealer)
  end
end

def play_for_player!(state)
  loop do
    you_have state
    return if busted?(state, :player) || max_score?(state, :player)
    dealer_shows state, 'shows'
    return unless player_turn?
    hit! state, :player
  end
end

def player_turn?
  prompt = "Hit (H) or Stay (S)?"
  loop do
    answer = prompt_and_read(prompt).downcase
    puts
    break answer == 'h' if answer.start_with?(*%w(h s))
    prompt = 'Invalid response. Please type H to hit, or S to stay.'
  end
end

def plural(quantity)
  quantity == 1 ? '' : 's'
end

def points_or_bust(scores)
  scores.empty? ? 'which is a bust.' : "for #{scores} points."
end

def possible_scores(state, who)
  join_or state[who][:scores]
end

def prompt_and_read(msg)
  puts msg
  print '> '
  gets.chomp
end

# ! because this terminates the program
def quit!(msg)
  puts msg
  exit 0
end

def record_win!(state)
  player = final_score(state, :player) || 0
  dealer = final_score(state, :dealer) || 0

  if dealer > player
    state[:dealer][:wins] += 1
  elsif player > dealer
    state[:player][:wins] += 1
  end
end

def report_results(state)
  player = final_score state, :player
  dealer = final_score state, :dealer

  if player.nil?
    puts 'You busted. Dealer wins!'
  elsif dealer.nil?
    puts 'Dealer busted. You win!'
  elsif player > dealer
    puts "You won #{player}-#{dealer}!"
  elsif dealer > player
    puts "Dealer won #{dealer}-#{player}."
  else
    puts "Tie game: #{player}-#{dealer}."
  end
end

def reset!(state)
  state[:deck] = new_deck
  [:player, :dealer].each { |who| state[who].merge!(hand: [], scores: [0]) }
end

def show_busted_or_max?(state, who, whohas)
  if busted? state, who
    puts "#{whohas} busted."
    true
  elsif max_score? state, who
    puts "#{whohas} #{state[:target]}."
    true
  end
end

def solicit_bust_value
  puts ''
  prompt = "What score should each hand play to? (default: #{BUST})"
  loop do
    answer = to_integer prompt_and_read(prompt), BUST, 11, 170
    puts
    return answer if answer
    prompt = 'Please enter a value between 11 and 170, inclusive.'
  end
end

def to_integer(value, default, min, max)
  result = value.empty? ? default : Integer(value)
  result if (min..max).include?(result)
rescue ArgumentError
  nil
end

def you_have(state)
  cards, scores = cards_and_possible_scores state, :player
  puts "You have been dealt <#{cards}> #{points_or_bust scores}"
end

if __FILE__ == $PROGRAM_NAME
  system 'clear'
  puts <<-EOS
Welcome to Eleventy-1!

This game is similar to blackjack, but it lacks double-downs, 5 card charlies,
and splits. It also allows the player to set the target score (21 by default).
The first player to win 5 games wins.

EOS

  # Cards are implemented as simple 2-element hashes:
  #
  # [:rank]    Rank value for card (2-10, :J, :Q, :K, :A)
  # [:values]  A list of possible values fpr the card
  #
  # We don't bother with suits since they are unimportant in this game.
  #
  # The state hash info:
  #
  # [:target]  The target score (e.g., 21)
  # [:deck]    The card deck (a 52 element array of cards treated as a stack)
  # [:player]  Information about the human player
  #   [:hand]     A list of cards that represent the player's hand
  #   [:scores]   A list of possible scores for the player's hand
  #   [:wins]     How many games has the player won?
  # [:dealer]  Information about the dealer
  #   [:hand]     A list of cards that represent the dealer's visible hand
  #   [:down]     The dealer's face-down card
  #   [:scores]   A list of possible scores for the player's visible hand
  #   [:wins]     How many games has the dealer won?

  state = {
    target: solicit_bust_value,
    player: { wins: 0 },
    dealer: { wins: 0 }
  }

  puts ''
  loop do
    reset! state
    play! state

    if state[:player][:wins] == MAX_POINTS
      quit! "Congratulations! You reached 5 wins first, and have won the " \
            "game #{state[:player][:wins]}-#{state[:dealer][:wins]}"
    elsif state[:dealer][:wins] == MAX_POINTS
      quit! "Sorry! The dealer reached 5 wins first, and you lost the game " \
            "#{state[:player][:wins]}-#{state[:dealer][:wins]}"
    else
      answer = prompt_and_read 'Type Q to quit, anything else for next hand.'
      exit 0 if answer.downcase.start_with? 'q'
      system 'clear'
    end
  end
end
