
data = {
  scores: [human: 0, computer: 0, tied: 0],
  degree: 3,
  first_player: :human,
  current_player: :computer,
  marker: {
    human: :X,
    computer: :O
  },
  board: {
    1 => :O,
    2 => ' ',
    3 => ' ',
    4 => :O,
    5 => :O,
    6 => :X,
    7 => ' ',
    8 => ' ',
    9 => :X
  }
}

display data
puts
p choose_best_move(data, data[:degree] - 1, :human)
p choose_best_move(data, data[:degree], :computer)
p choose_best_move(data, data[:degree] - 1, :computer)
p choose_best_move(data, data[:degree], :human)
exit 0
