flintstones = %w(Fred Barney Wilma Betty BamBam Pebbles)
flintstones.map! { |who| who[0,3] }
p flintstones
