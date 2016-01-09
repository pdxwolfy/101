def a_number?(word)
  (0..255).include? Integer(word)
rescue ArgumentError
  false
end

def dot_separated_ip_address?(input_string)
  dot_separated_words = input_string.split(".")
  return false unless dot_separated_words.size == 4
  while dot_separated_words.size > 0
    word = dot_separated_words.pop
    return false unless a_number?(word)
  end
  true
end

def test(value, expect)
  puts "#{value}: #{dot_separated_ip_address?(value)}   expect #{expect}"
end

test('1.2.3.4', true)
test('255.255.255.255', true)
test('255.0.255.255', true)
test('255.0.256.255', false)
test('192.168.255', false)
test('192.168', false)
test('192.168.5.10.15', false)
test('999.0.0.0', false)
test('999.0.0.999', false)
test('0.0.0.256', false)
test('0.0.0.255', true)
