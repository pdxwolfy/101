def titleize(str)
  str.split.map(&:capitalize).join ' '
end

puts titleize('four sCORE and seven years ago')
puts titleize('2001: a space odySSey')
