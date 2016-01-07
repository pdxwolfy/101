# Car loan/mortgage payment calculator
#
# Source Formulae:    http://www.mtgprofessor.com/formulas.htm
#
#               c (1 + c)^n
#         P = L -------------
#               (1 + c)^n - 1
#
#    c - monthly interest rate = APR / 12
#    n - loan duration in months
#    L - total loan amount
#    P - monthly payment
#
# Process:
#    Solicit loan amount (L) in dollars
#    Solicit APR (i) as a number between 0.0 and 1.0.
#    Solicit loan duration (n) in months
#    Calculate c = APR / 12
#    Calculate P = ....
#    Display results
