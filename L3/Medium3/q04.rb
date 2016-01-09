def tricky_method_two(a_string_param, an_array_param)
  a_string_param.gsub!('pumpkins', 'rutabaga')
  an_array_param = ['pumpkins', 'rutabaga']
end

my_string = "pumpkins"
my_array = ["pumpkins"]
tricky_method_two(my_string, my_array)

puts "My string looks like this now: #{my_string}"
puts "My string looks like this now: rutabaga"
puts "because my_string is mutated by gsub!"
puts ''
puts "My array looks like this now: #{my_array}"
puts "My array looks like this now: [\"pumpkins\"]"
puts "because my_array is NOT mutated by ="
