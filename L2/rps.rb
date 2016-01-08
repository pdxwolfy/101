VALID_CHOICES = %w(rock paper scissors)

def prompt(message)
  puts "=> #{message}"
end

# Renaming as results() so it doesn't appear to be printing something.
def results(player, computer)
  if (player == 'rock' && computer == 'scissors') ||
     (player == 'paper' && computer == 'rock') ||
     (player == 'scissors' && computer == 'paper')
    'You won!'
  elsif (player == 'rock' && computer == 'paper') ||
        (player == 'paper' && computer == 'scissors') ||
        (player == 'scissors' && computer == 'rock')
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
