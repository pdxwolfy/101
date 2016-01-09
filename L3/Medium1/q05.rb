# def factors(number)
#   dividend = number
#   divisors = []
#   begin
#     divisors << number / dividend if number % dividend == 0
#     dividend -= 1
#   end until dividend == 0
#   divisors
# end

def factors(number)
  dividend = number
  divisors = []
  until dividend <= 0
    divisors << number / dividend if number % dividend == 0
    dividend -= 1
  end
  divisors
end

p factors(357)
p factors(1024)
p factors(10)
p factors(7)
p factors(151)
p factors(1)
p factors(0)
p factors(-7)
p factors(-10)

# Bonus 1: {number % dividend == 0} is true if {dividend} is a factor of
#          {number}, false otherwise
# Bonus 2: the next to last line of the method provides the return value - an
#          Array that contains all of the divisors of {number}.
