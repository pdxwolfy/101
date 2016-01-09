flintstones = %w(Fred Barney Wilma Betty BamBam Pebbles)
puts flintstones.find_index { |who| who.start_with? 'Be' }
