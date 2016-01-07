# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

prompt "Welcome to Calculator"

prompt "What's the first number?"
number1 = gets.chomp

prompt "What's the second number?"
number2 = gets.chomp

prompt "What operation would you like to perform? 1) add 2) subtract 3) multiply 4) divide"
operator = gets.chomp

if operator == '1'
  result = number1.to_i + number2.to_i
elsif operator == '2'
  result = number1.to_i - number2.to_i
elsif operator == '3'
  result = number1.to_i * number2.to_i
elsif operator == '4'
  result = number1.to_f / number2.to_f
end

prompt "The result is #{result}"
