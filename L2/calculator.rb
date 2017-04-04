require 'yaml'

LANGUAGE = 'en'
MESSAGES = YAML.load_file('messages.yml')

def messages(message, language = LANGUAGE)
  MESSAGES[language][message]
end

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
    '1' => messages('adding'),
    '2' => messages('subtracting'),
    '3' => messages('multiplying'),
    '4' => messages('dividing')
  }

  lookup_table[operator]
end

prompt messages('welcome')

name = ''
loop do
  name = gets.chomp
  break unless name.empty?
  prompt messages('use_real_name')
end

prompt format(messages('hello'), name: name)

loop do
  number1 = ''
  loop do
    prompt messages('first_number')
    number1 = gets.chomp
    break if number? number1
    prompt messages('bad_number')
  end

  number2 = ''
  loop do
    prompt messages('second_number')
    number2 = gets.chomp
    break if number? number2
    prompt messages('bad_number')
  end

  operator = ''
  prompt messages('what_op')
  loop do
    operator = gets.chomp
    break if %(1 2 3 4).include? operator
    prompt messages('bad_op')
  end

  prompt format(messages('will_do'), operating: operation_verbing(operator),
                                     number1: number1,
                                     number2: number2)

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

  prompt format(messages('result_is'), result: result)
  prompt messages('another_calc')
  answer = gets.chomp.downcase
  break unless answer.start_with? messages('yes')
end

prompt messages('thank_you')
