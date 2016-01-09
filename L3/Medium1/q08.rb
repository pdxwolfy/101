def titleize_old(str)
  str.split.map(&:capitalize).join ' '
end

puts titleize_old('four sCORE and seven years ago')
puts titleize_old('2001: a space odySSey')

DO_NOT_CAPITALIZE = %w(a an the at by for in into of on to up and as but or nor)
END_PHRASE = /([-.:!?]+\s+)/

def capitalize_always(word)
  !DO_NOT_CAPITALIZE.include?(word)
end

def titleize_phrase(phrase)
  words = phrase.downcase.split.map do |word|
    capitalize_always(word) ? word.capitalize : word
  end
  words.first.capitalize! # First and last word are always capitalized.
  words.last.capitalize!
  words.join ' '
end

def titleize(str)
  str.split(END_PHRASE).map { |phrase| titleize_phrase(phrase) }.join
end

puts titleize 'star wars: the force awakens'
puts titleize 'four sCORE and seven years ago'
puts titleize '2001: a space odySSey'
puts titleize 'MASTER AND COMMANDER: THE FAR SIDE OF THE WORLD'
puts titleize 'a star is born'
puts titleize 'Every which Way but up'
