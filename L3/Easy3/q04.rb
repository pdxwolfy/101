advice = "Few things in life are as important as house training your pet dinosaur."
advice.sub!(/\s+house.*/, '')
puts advice

advice = "Few things in life are as important as house training your pet dinosaur."
puts advice.slice! 'Few things in life are as important as '
puts advice

advice = "Few things in life are as important as house training your pet dinosaur."
puts advice.slice 'Few things in life are as important as '
puts advice # should print original advice string
