flintstones = %w(Fred Barney Wilma Betty Peddles BamBam)
name_and_index = flintstones.map.each_with_index do |name, index|
  [name, index]
end
flintstones_hash = name_and_index.to_h
p flintstones_hash
