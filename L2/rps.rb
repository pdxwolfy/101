VALID_CHOICES = %w(rock paper scissors)

def display_results(player, computer)
  prompt "You chose #{player}. Computer chose #{computer}."
  if (player == 'rock' && computer == 'scissors') ||
     (player == 'paper' && computer == 'rock') ||
     (player == 'scissors' && computer == 'paper')
    prompt 'You won!'
  elsif (player == 'rock' && computer == 'paper') ||
        (player == 'paper' && computer == 'scissors') ||
        (player == 'scissors' && computer == 'rock')
    prompt 'Computer won!'
  else
    prompt 'Tie game!'
  end
end

def prompt(message)
  puts "=> #{message}"
end

loop do
  choice = ''
  loop do
    prompt "Choose one: #{VALID_CHOICES.join ', '}"
    choice = Kernel.gets.chomp
    break if VALID_CHOICES.include? choice
    prompt "That is not a valid choice."
  end

  display_results choice, VALID_CHOICES.sample

  prompt "Do you want to play again?"
  answer = gets.chomp
  break unless answer.start_with? 'y'
end
