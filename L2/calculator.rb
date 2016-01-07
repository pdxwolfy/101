load 'messages.en'

# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

# Return true if #{value} is a valid integer, false otherwise.
def number?(value)
  Float(value)
rescue ArgumentError
  false
end

# Convert operation shorthand to an -ing verb.
def operation_verbing(operator)
  lookup_table = {
    '1' => MESSAGES[:ADDING],
    '2' => MESSAGES[:SUBTRACTING],
    '3' => MESSAGES[:MULTIPLYING],
    '4' => MESSAGES[:DIVIDING]
  }

  lookup_table[operator]
end

prompt MESSAGES[:WELCOME]

name = ''
loop do
  name = gets.chomp
  break unless name.empty?
  prompt MESSAGES[:USE_REAL_NAME]
end

prompt MESSAGES[:HELLO] % { name: name }

loop do
  number1 = ''
  loop do
    prompt MESSAGES[:FIRST_NUMBER]
    number1 = gets.chomp
    break if number? number1
    prompt MESSAGES[:BAD_NUMBER]
  end

  number2 = ''
  loop do
    prompt MESSAGES[:SECOND_NUMBER]
    number2 = gets.chomp
    break if number? number2
    prompt MESSAGES[:BAD_NUMBER]
  end

  operator = ''
  prompt MESSAGES[:WHAT_OP]
  loop do
    operator = gets.chomp
    break if %(1 2 3 4).include? operator
    prompt MESSAGES[:BAD_OP]
  end

  prompt MESSAGES[:WILL_DO] % {
    operating: operation_verbing(operator),
    number1: number1,
    number2: number2
  }

  result =
    case operator
    when '1'
      number1.to_f + number2.to_f
    when '2'
      number1.to_f - number2.to_f
    when '3'
      number1.to_f * number2.to_f
    when '4'
      # Warn: possible divide by 0 if 0 input is allowed
      number1.to_f / number2.to_f
    end

  prompt MESSAGES[:RESULT_IS] % { result: result }
  prompt MESSAGES[:ANOTHER_CALC]
  answer = gets.chomp.downcase
  break unless answer.start_with? MESSAGES[:YES]
end

prompt MESSAGES[:THANK_YOU]
