require 'yaml'

MESSAGES = YAML.load_file('messages.yml')

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
    '1' => MESSAGES['adding'],
    '2' => MESSAGES['subtracting'],
    '3' => MESSAGES['multiplying'],
    '4' => MESSAGES['dividing']
  }

  lookup_table[operator]
end

prompt MESSAGES['welcome']

name = ''
loop do
  name = gets.chomp
  break unless name.empty?
  prompt MESSAGES['use_real_name']
end

prompt MESSAGES['hello'] % { name: name }

loop do
  number1 = ''
  loop do
    prompt MESSAGES['first_number']
    number1 = gets.chomp
    break if number? number1
    prompt MESSAGES['bad_number']
  end

  number2 = ''
  loop do
    prompt MESSAGES['second_number']
    number2 = gets.chomp
    break if number? number2
    prompt MESSAGES['bad_number']
  end

  operator = ''
  prompt MESSAGES['what_op']
  loop do
    operator = gets.chomp
    break if %(1 2 3 4).include? operator
    prompt MESSAGES['bad_op']
  end

  prompt MESSAGES['will_do'] % {
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

  prompt MESSAGES['result_is'] % { result: result }
  prompt MESSAGES['another_calc']
  answer = gets.chomp.downcase
  break unless answer.start_with? MESSAGES['yes']
end

prompt MESSAGES['thank_you']
