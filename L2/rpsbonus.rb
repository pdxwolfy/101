# Rock, Paper, Scissors, Lizard, Spock game.
# Pete Hanson

VALID_CHOICES = { # abbreviation => full value
  'r'  => 'rock',
  'p'  => 'paper',
  'sc' => 'scissors',
  'sp' => 'spock',
  'l'  => 'lizard'
}

WINNING_COMBOS = { # player1 choice => player2 choice
  'rock'     => %w(scissors lizard),
  'paper'    => %w(rock spock),
  'scissors' => %w(paper lizard),
  'lizard'   => %w(paper spock),
  'spock'    => %w(scissors rock)
}

MESSAGES = {
  abbreviations:    <<-EOS,
You may abbreviate choices as follows:
    r  -> rock
    p  -> paper
    sc -> scissors
    l  -> lizard
    sp -> spock
EOS
  choose_one:       'Choose one',
  computer_won:     'Computer won this round.',
  congratulations:  'Congratulations. You won!',
  invalid_choice:   'That is not a valid choice.',
  thanks_and_bye:   'Bye! Thanks for playing.',
  the_choices_were: 'You chose %{player}. The computer chose %{computer}.',
  the_score_is:     'Score is:  you %{player}  me %{computer}',
  tie:              'Tie: nobody won this round.',
  welcome:          'Welcome to Rock, Paper, Scissors, Lizard, Spock!',
  you_lost:         'Sorry. You lost. Go me!',
  you_won:          'You won this round.'
}

WINNING_SCORE = 5  # First player to this score wins.

def game_over?(scores)
  scores.any? { |_, score| score >= WINNING_SCORE }
end

def fetch_choice
  print "> "
  choice = gets.chomp.downcase
  puts ""
  VALID_CHOICES.key?(choice) ? VALID_CHOICES[choice] : choice
end

def results(player, computer)
  if win?(player, computer)
    :you_won
  elsif win?(computer, player)
    :computer_won
  else
    :tie
  end
end

def show_choices(player, computer)
  choices = { player: player, computer: computer }
  puts format(MESSAGES[:the_choices_were], choices)
end

def solicit_choice
  main_prompt = "#{MESSAGES[:choose_one]}: #{VALID_CHOICES.values.join ', '}"
  puts main_prompt, MESSAGES[:abbreviations]
  loop do
    choice = fetch_choice
    return choice if VALID_CHOICES.values.include? choice

    puts MESSAGES[:invalid_choice], main_prompt
  end
end

def win?(player1, player2)
  WINNING_COMBOS[player1].include? player2
end

puts MESSAGES[:welcome]
scores = { player: 0, computer: 0 }

loop do
  player_choice = solicit_choice
  computer_choice = VALID_CHOICES.values.sample
  system 'clear'
  show_choices player_choice, computer_choice

  round_result = results(player_choice, computer_choice)
  if round_result == :you_won
    scores[:player] += 1
  elsif round_result == :computer_won
    scores[:computer] += 1
  end
  puts MESSAGES[round_result], format(MESSAGES[:the_score_is], scores), ""

  break if game_over? scores
end

end_state = (scores[:player] > scores[:computer]) ? :congratulations : :you_lost
puts MESSAGES[end_state], MESSAGES[:thanks_and_bye]
