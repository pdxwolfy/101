def tricky_method(a_string_param, an_array_param)
  a_string_param += "rutabaga"
  an_array_param << "rutabaga"
end

my_string = "pumpkins"
my_array = ["pumpkins"]
tricky_method(my_string, my_array)

puts "My string looks like this now: #{my_string}"
puts "My array looks like this now: #{my_array}"

# Will output as follows
puts "My string looks like this niw: pumpkins"
# because my_string is not altered by tricky_method()
puts "My array looks like this niw: [\"pumpkins\", \"rutabaga\"]"
# because my_array is mutated by tricky_method()
