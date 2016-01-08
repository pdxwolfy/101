VALID_CHOICES = %w(rock paper scissors spock lizard)
WINNING_COMBOS = { # my choice => computer choice
  'rock' => %w(scissors lizard),
  'paper' => %w(rock spock),
  'scissors' => %w(paper lizard),
  'lizard' => %w(paper spock),
  'spock' => %w(scissors rock)
}

#-----------------------------------------------------------------------------
# Display a prompt or other message
def prompt(message)
  puts "=> #{message}"
end

#-----------------------------------------------------------------------------
# Returns a string that describes whether the play won, the computer won, or
# there was a tie game.
def results(player, computer)
  if win?(player, computer)
    'You won!'
  elsif win?(computer, player)
    'Computer won!'
  else
    'Tie game!'
  end
end

#-----------------------------------------------------------------------------
# Asks user for their choice (rock, paper, scissors) and returns that value.
def solicit_choice
  loop do
    prompt "Choose one: #{VALID_CHOICES.join ', '}"
    choice = Kernel.gets.chomp
    return choice if VALID_CHOICES.include? choice

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
loop do
  player_choice = solicit_choice
  computer_choice = VALID_CHOICES.sample
  prompt "You chose #{player_choice}. Computer chose #{computer_choice}."
  prompt results(player_choice, computer_choice)

  prompt "Do you want to play again?"
  answer = gets.chomp
  break unless answer.start_with? 'y'
end
prompt "Bye! Thanks for playing."
