VALID_CHOICES = %w(rock paper scissors)
WINNING_COMBOS = { # my choice => computer choice
  'rock' => 'scissors',
  'paper' => 'rock',
  'scissors' => 'paper'
}

def prompt(message)
  puts "=> #{message}"
end

def win?(player1, player2)
  WINNING_COMBOS[player1] == player2
end

# Renaming as results() so it doesn't appear to be printing something.
def results(player, computer)
  if win?(player, computer)
    'You won!'
  elsif win?(computer, player)
    'Computer won!'
  else
    'Tie game!'
  end
end

loop do
  choice = ''
  loop do
    prompt "Choose one: #{VALID_CHOICES.join ', '}"
    choice = Kernel.gets.chomp
    break if VALID_CHOICES.include? choice
    prompt "That is not a valid choice."
  end

  computer_choice = VALID_CHOICES.sample
  prompt "You chose #{choice}. Computer chose #{computer_choice}."
  # We need to print the results
  prompt results(choice, computer_choice)

  prompt "Do you want to play again?"
  answer = gets.chomp
  break unless answer.start_with? 'y'
end
