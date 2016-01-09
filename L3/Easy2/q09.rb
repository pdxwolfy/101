flintstones = %w(Fred Barney Wilma Betty BamBam Pebbles)
flintstones.map! { |who| who[0..2] }
p flintstones
