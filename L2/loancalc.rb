# Car loan/mortgage payment calculator
#
# Source Formulae:    http://www.mtgprofessor.com/formulas.htm
#
#               c (1 + c)^n
#         P = L -------------
#               (1 + c)^n - 1
#
#    c - monthly interest rate = APR / 12 scaled to 0 .. 1
#    n - loan duration in months
#    L - total loan amount
#    P - monthly payment
#
# Process:
#    Solicit loan amount (L) in dollars
#    Solicit APR (i) as a number between 0 and 100.
#    Solicit loan duration (n) in months
#    Calculate c = APR / 12
#    Calculate P = ....
#    Display results

require 'yaml'

LANGUAGE = 'en'
MESSAGES = YAML.load_file('loancalc.yml')[LANGUAGE]

#-----------------------------------------------------------------------------
# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

#-----------------------------------------------------------------------------
# Get loan amount from user. Returns non-negative float.
def loan_amount
  loop do
    amount = solicit MESSAGES['enter_amount']
    return amount.to_f if valid_dollar_amount? amount
    prompt MESSAGES['bad_amount']
  end
end

#-----------------------------------------------------------------------------
# Get loan APR from user. Returns float between 0.0 and 1.0
def loan_apr
  loop do
    apr = solicit MESSAGES['enter_apr']
    return apr.to_f if valid_apr? apr
    prompt MESSAGES['bad_apr']
  end
end

#-----------------------------------------------------------------------------
# Get loan duration in years. Returns integer.
def loan_duration_in_years
  loop do
    duration = solicit MESSAGES['enter_duration']
    return duration.to_i if valid_duration? duration
    prompt MESSAGES['bad_duration']
  end
end

#-----------------------------------------------------------------------------
# Display a prompt and get a string
def solicit(message)
  prompt(message)
  gets.chomp
end

#-----------------------------------------------------------------------------
# Return true if #{value} can be properly represented as an APR between 0.00
# and 1.00, false otherwise.
def valid_apr?(value)
  valid_non_negative_float?(value) && value.to_f <= 1.00
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as a dollar amount.
def valid_dollar_amount?(value)
  valid_non_negative_float? value
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as a valid duration in
# years.
def valid_duration?(value)
  valid_non_negative_integer? value
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as a floating point
# number, false otherwise.
def valid_float?(value)
  Float value
rescue ArgumentError
  false
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as an Integer, false
# otherwise.
def valid_integer?(value)
  Integer value
rescue ArgumentError
  false
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as a non-negative
# floating point number, false otherwise.
def valid_non_negative_float?(value)
  valid_float?(value) && value.to_f >= 0.00
end

#-----------------------------------------------------------------------------
# Returns true if #{value} can be properly represented as a non-negative
# integer, false otherwise.
def valid_non_negative_integer?(value)
  valid_integer?(value) && value.to_i >= 0
end

#-----------------------------------------------------------------------------
# Main processing
prompt MESSAGES['welcome']
loop do
  amount = loan_amount
  apr = loan_apr
  monthly_rate = apr / 12.0
  months = 12 * loan_duration_in_years
  factor = (1 + monthly_rate)**months
  payment = amount * (factor * monthly_rate) / (factor - 1)
  prompt format(MESSAGES['results'], amount, months, apr, payment)

  answer = solicit MESSAGES['try_again']
  break unless answer.downcase.start_with? MESSAGES['yes']
end
