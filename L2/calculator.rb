# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

# Return true if #{value} is a valid integer, false otherwise.
def number?(value)
  Integer(value)
rescue ArgumentError
  false
end

# Convert operation shorthand to an -ing verb.
def operation_verbing(operator)
  case operator
  when '1'
    'Adding'
  when '2'
    'Subtracting'
  when '3'
    'Multiplying'
  when '4'
    'Dividing'
  end
end

prompt "Welcome to Calculator. Enter your name:"

name = ''
loop do
  name = gets.chomp
  break unless name.empty?
  prompt "Make sure you use your real name."
end

prompt "Hi #{name}!"

loop do
  number1 = ''
  loop do
    prompt "What's the first number?"
    number1 = gets.chomp
    break if number? number1
    prompt "#{number1} does not look like a valid number"
  end

  number2 = ''
  loop do
    prompt "What's the second number?"
    number2 = gets.chomp
    break if number? number2
    prompt "#{number2} does not look like a valid number"
  end

  operator = ''
  prompt <<-EOS
    What operation would you like to perform?
    1) add
    2) subtract
    3) multiply
    4) divide
  EOS

  loop do
    operator = gets.chomp
    break if %(1 2 3 4).include? operator
    prompt "Please enter 1, 2, 3, or 4"
  end

  prompt "#{operation_verbing operator} #{number1} and #{number2}"
  result =
    case operator
    when '1'
      number1.to_i + number2.to_i
    when '2'
      number1.to_i - number2.to_i
    when '3'
      number1.to_i * number2.to_i
    when '4'
      # Warn: possible divide by 0 if 0 input is allowed
      number1.to_f / number2.to_f
    end

  prompt "The result is #{result}"
  prompt "Do you want to perform another calculation (Y for yes)?"
  answer = gets.chomp.downcase
  break unless answer.start_with? 'y'
end

prompt "Thank you for using Calculator. Bye!"
