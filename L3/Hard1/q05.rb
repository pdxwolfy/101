def is_a_number?(word)
  (0..255).include? Integer(word)
rescue ArgumentError
  false
end

def dot_separated_ip_address?(input_string)
  dot_separated_words = input_string.split(".")
  return false unless dot_separated_words.size == 4
  while dot_separated_words.size > 0 do
    word = dot_separated_words.pop
    return false if !is_a_number?(word)
  end
  return true
end

def test(value)
  puts "#{value}: #{dot_separated_ip_address?(value)}"
end

test('1.2.3.4')
test('255.255.255.255')
test('255.0.255.255')
test('255.0.256.255')
test('192.168.255')
test('192.168')
test('192.168.5.10.15')
test('999.0.0.0')
test('999.0.0.999')
test('0.0.0.256')
test('0.0.0.255')
