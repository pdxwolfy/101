# This will fail because {limit} is a local variable, so is thus not available
# in the fib() metod.
#
# limit = 15
#
# def fib(first_num, second_num)
#   while second_num < limit
#     sum = first_num + second_num
#     first_num = second_num
#     second_num = sum
#   end
#   sum
# end
#
# result = fib(0, 1)
# puts "result is #{result}"
#
# To fix it, convert {limit} to a CONSTANT.

LIMIT = 15

def fib(first_num, second_num)
  while second_num < LIMIT
    sum = first_num + second_num
    first_num = second_num
    second_num = sum
  end
  sum
end

result = fib(0, 1)
puts "result is #{result}"

# Alternatively, {limit} can be passed to fib() as a parameter.
