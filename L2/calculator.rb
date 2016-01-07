# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

# Return true if #{value} is a valid number, false otherwise.
# Currently returns false is #{value} is "0" or equivalent value.
# Currently returns true if #{value} just starts with a number
def valid_number?(value)
  value.to_i != 0
end

prompt "Welcome to Calculator"

number1 = ""
loop do
  prompt "What's the first number?"
  number1 = gets.chomp
  break if valid_number? number1
  prompt "#{number1} does not look like a valid number"
end

number2 = ""
loop do
  prompt "What's the second number?"
  number2 = gets.chomp
  break if valid_number? number2
  prompt "#{number2} does not look like a valid number"
end

prompt "What operation would you like to perform? 1) add 2) subtract 3) multiply 4) divide"
operator = gets.chomp

result = case operator
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
