VALID_CHOICES = %w(rock paper scissors)

def prompt(message)
  puts "=> #{message}"
end

choice = ''
loop do
  prompt "Choose one: #{VALID_CHOICES.join ', '}"
  choice = Kernel.gets.chomp
  break if VALID_CHOICES.include? choice
  prompt "That is not a valid choice."
end

computer_choice = VALID_CHOICES.sample
if (choice == 'rock' && computer_choice == 'scissors') ||
   (choice == 'paper' && computer_choice == 'rock') ||
   (choice == 'scissors' && computer_choice == 'paper')
  prompt 'You won!'
elsif (choice == 'rock' && computer_choice == 'paper') ||
      (choice == 'paper' && computer_choice == 'scissors') ||
      (choice == 'scissors' && computer_choice == 'rock')
  prompt 'You lost!'
else
  prompt 'Tie game!'
end

puts "You chose #{choice}. Computer chose #{computer_choice}."
