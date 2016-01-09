CLUSTER_LENGTHS = [8, 4, 4, 4, 12]

def random_hex_string(length)
  length.times.map { rand(16).to_s(16) }.join
end

def uuid
  CLUSTER_LENGTHS.map { |length| random_hex_string(length) }.join '-'
end

puts uuid
