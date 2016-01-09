# The following should print:
#
#    1
#    3
#
# and should change numbers to [3, 4]
numbers = [1, 2, 3, 4]
numbers.each do |number|
  p number
  numbers.shift(1)
end

p numbers

# The following should print:
#
#    1
#    2
#
# and should change numbers to [1, 2]
numbers = [1, 2, 3, 4]
numbers.each do |number|
  p number
  numbers.pop(1)
end

p numbers
