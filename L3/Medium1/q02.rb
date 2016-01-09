statement = "The Flintstones Rock"
frequency = Hash.new 0
statement.chars.each { |letter| frequency[letter] += 1 }
p frequency
