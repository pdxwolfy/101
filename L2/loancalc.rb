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

# Display a prompt
def prompt(message)
  puts "=> #{message}"
end

prompt MESSAGES['welcome']
