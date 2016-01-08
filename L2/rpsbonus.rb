# Rock, Paper, Scissors, Lizard, Spock game.
# Pete Hanson

VALID_CHOICES = { # abbreviation => full value
  'r'  => 'rock',
  'p'  => 'paper',
  'sc' => 'scissors',
  'sp' => 'spock',
  'l'  => 'lizard'
}

WINNING_COMBOS = { # my choice => computer choice
  'rock'     => %w(scissors lizard),
  'paper'    => %w(rock spock),
  'scissors' => %w(paper lizard),
  'lizard'   => %w(paper spock),
  'spock'    => %w(scissors rock)
}

MESSAGES = {
  abbreviations:  <<-EOS,
You may abbreviate choices as follows:
    r  -> rock
    p  -> paper
    sc -> scissors
    l  -> lizard
    sp -> spock
  EOS
  computer_won:    'Computer won this round.',
  congratulations: 'Congratulations. You won!',
  thanks_and_bye:  'Bye! Thanks for playing.',
  tie:             'Tie: nobody won this round.',
  welcome:         'Welcome to Rock, Paper, Scissors, Lizard, Spock!',
  you_lost:        'Sorry. You lost. Go me!',
  you_won:         'You won this round.'
}

WINNING_SCORE = 5  # First player to this score wins.

#-----------------------------------------------------------------------------
# Returns true if the game is over, false otherwise.

def game_over?(scores)
  scores.any? { |_, score| score >= WINNING_SCORE }
end

#-----------------------------------------------------------------------------
# Display a prompt or other message
def prompt(message)
  puts "=> #{message}"
end

#-----------------------------------------------------------------------------
# Returns a symbol (:you_won, :computer_won, or :tie) depending on whether the
# player or computer won this round.
def results(player, computer)
  if win?(player, computer)
    :you_won
  elsif win?(computer, player)
    :computer_won
  else
    :tie
  end
end

#-----------------------------------------------------------------------------
# Asks user for their choice (rock, paper, scissors) and returns that value.
def solicit_choice
  loop do
    prompt "Choose one: #{VALID_CHOICES.values.join ', '}"
    choice = Kernel.gets.chomp.downcase
    choice = VALID_CHOICES[choice] if VALID_CHOICES.key? choice
    return choice if VALID_CHOICES.values.include? choice

    prompt "That is not a valid choice."
  end
end

#-----------------------------------------------------------------------------
# Return true if player1's play (rock, paper, scissors) beats player2's play,
# false otherwise.
def win?(player1, player2)
  WINNING_COMBOS[player1].include? player2
end

#-----------------------------------------------------------------------------
# Main processing. Keeps repeating until user doesn't want to continue.

prompt MESSAGES[:welcome]
prompt MESSAGES[:abbreviations]
scores = Hash.new 0

loop do
  player_choice = solicit_choice
  computer_choice = VALID_CHOICES.values.sample
  prompt "You chose #{player_choice}. Computer chose #{computer_choice}."

  round_result = results(player_choice, computer_choice)
  if round_result == :you_won
    scores[:player] += 1
  elsif round_result == :computer_won
    scores[:computer] += 1
  end
  prompt MESSAGES[round_result]
  prompt "Score is:  you #{scores[:player]}    me #{scores[:computer]}"

  break if game_over? scores
end

if scores[:player] > scores[:computer]
  prompt MESSAGES[:congratulations]
else
  prompt MESSAGES[:you_lost]
end

prompt MESSAGES[:thanks_and_bye]
