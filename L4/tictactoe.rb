# Tic-Tac-Toe game
# Pete Hanson

INITIAL_MARKER = ' '
X_MARKER = :X
O_MARKER = :O

THE_PLAYERS = [:human, :computer]
WINNING_SCORE = 5

MESSAGES = {
  bad_board_degree:   'Board size should be between 3 and 9, inclusive.',
  cell_not_available: 'That square is either not available or invalid.',
  congratulations:    'You won. Congratulations!',
  continue:           'Press [Return] for next game, or type Q to quit.',
  current_score:      'Current score:     ',
  final_score:        'Final score:    ',
  get_board_degree:   "What degree board do you want (3-9)?\n" \
                      "A degree 3 board is 3x3 and needs 3 in a row to win.\n" \
                      "A degree 4 board is 4x4 and needs 4 in a row to win.\n" \
                      'And so on...',
  go_first:           'Would you like to go first (Y for yes)?',
  i_selected:         'I selected square number %{move}',
  instructions:       'You are an %{human}. ' \
                      "The computer is an %{computer}\n" \
                      'You may enter Q at any time to quit.',
  overall_loss:       'You lost the match.',
  overall_tie:        'The match was a tie.',
  overall_win:        'You won the match.',
  play_prompt:        'Please enter your move: %{available}',
  numbering:          "Squares are numbered as:\n\n",
  the_score:          "You: %{human}  Me: %{computer}  Tied: %{tied}",
  tie_game:           'Tie game. Sigh.',
  you_lost:           'Tic! Tac! Toe! You lost. Sorry!'
}

FINAL_GAME_STATUS = {
  human:    :congratulations,
  computer: :you_lost,
  tied:     :tie_game
}

FINAL_MATCH_STATUS = {
  human:    :overall_win,
  computer: :overall_loss,
  tied:     :overall_tie
}

#-----------------------------------------------------------------------------
# Methods to manage board and movement key

def display_board(data)
  puts message(:instructions, data[:marker]), ''
  ncells = data[:degree]
  out = '---+' * (ncells - 1) + '---'
  (1..data[:board].size).each_slice(ncells) do |row|
    puts "#{out}      #{out}" unless row[0] == 1
    display_row data, row
  end
end

def display_row(data, row)
  print [row.map { |cell| " #{data[:board][cell]} " }].join('|')
  print '      '
  puts [row.map { |cell| format(' %-2s', cell) }].join('|')
end

def new_board(degree)
  Hash[(1..(degree * degree)).map { |n| [n, INITIAL_MARKER] }]
end

#-----------------------------------------------------------------------------
# Methods to manage/determine game state

def empty_cells(data)
  data[:board].select { |_, status| status == INITIAL_MARKER }.keys
end

def game_over?(data)
  winner(data) || tied_game?(data)
end

def game_status(data)
  status = winner data
  if status
    status
  elsif tied_game? data
    :tied
  end
end

def key_columns(data)
  board = data[:board]
  degree = data[:degree]
  (1..degree).map { |n| (n..board.size).step(degree).to_a }
end

def key_diagonals(data)
  board = data[:board]
  degree = data[:degree]
  diag1 = (1..board.size).step(degree + 1).to_a
  diag2 = (degree..board.size - 1).step(degree - 1).to_a
  [diag1, diag2]
end

# A "key line" is any row, column, or diagonal on the board that is not
# occupied by both players.
def key_lines(data)
  lines = key_rows(data) + key_columns(data) + key_diagonals(data)
  lines.reject do |key_line|
    kvalues = key_values(data, key_line)
    THE_PLAYERS.all? { |player| kvalues.include?(player) }
  end
end

def key_rows(data)
  (1..data[:board].size).each_slice(data[:degree]).to_a
end

def key_values(data, key_line)
  data[:board].values_at(*key_line)
end

def match_over?(data)
  return true if data[:scores].values_at(*THE_PLAYERS).max >= WINNING_SCORE
  puts message(:continue)
  print '> '
  gets.chomp.downcase == 'q'
end

# Returns all lines that have exactly "number" markers for "player" and none
# for the other player.
def n_in_a_row(data, number, player)
  other = data[:marker][other_player(player)]
  the_player = data[:marker][player]
  key_lines(data).select do |kline|
    count = key_values(data, kline).each_with_object(Hash.new(0)) do |item, acc|
      acc[item] += 1
    end
    count[the_player] == number && count[other] == 0
  end
end

def tied_game?(data)
  empty_cells(data).empty?
end

def winner(data)
  THE_PLAYERS.find do |player|
    !n_in_a_row(data, data[:degree], player).empty?
  end
end

#-----------------------------------------------------------------------------
# Methods used to manage and report scoring

def new_scores
  { human: 0, computer: 0, tied: 0 }
end

def record_score!(data, the_winner)
  data[:scores][the_winner] += 1
end

def report_final_score(data)
  scores = data[:scores]
  player = data[:current_player]
  the_winner = (scores[player] > scores[other_player player]) ? player : :tied
  puts message(FINAL_MATCH_STATUS[the_winner])
  print message(:final_score)
  puts message(:the_score, data[:scores])
end

def report_score(data)
  print message(:current_score)
  puts message(:the_score, data[:scores])
end

#-----------------------------------------------------------------------------
# Methods to manage computer's play selection

def choose_best_move(data, ncheck, player)
  check_cells = n_in_a_row(data, ncheck, player)
  unless check_cells.empty?
    values = key_values(data, check_cells[0])
    available = values.find_index INITIAL_MARKER
    check_cells[0][available] if available
  end
end

def choose_center_cell(data)
  data[:degree].odd? ? choose_center_odd(data) : choose_center_even(data)
end

def choose_center_even(data)
  degree = data[:degree]
  center = (data[:board].size - degree) / 2
  cells = [center, center + degree + 1, center + 1, center + degree]
  cells.find { |cell| data[:board][cell] == INITIAL_MARKER }
end

def choose_center_odd(data)
  center = (data[:board].size + 1) / 2
  center if data[:board][center] == INITIAL_MARKER
end

def choose_defensive_move(data)
  choose_best_move(data, data[:degree] - 1, :human)
end

def choose_move(data)
  choose_offensive_move(data) ||
    choose_defensive_move(data) ||
    choose_center_cell(data) ||
    empty_cells(data).sample
end

def choose_offensive_move(data)
  choose_best_move(data, data[:degree], :computer)
end

#-----------------------------------------------------------------------------
# Methods to manage play

def computer_move(data)
  move = choose_move(data)
  puts '', message(:i_selected, move: move)
  move
end

def init_player!(data)
  data[:first_player] = data[:current_player]
  data[:marker] = if data[:first_player] == :human
                    { human: X_MARKER, computer: O_MARKER }
                  else
                    { human: O_MARKER, computer: X_MARKER }
                  end
end

def move!(data)
  player = data[:current_player]
  move = (player == :human) ? player_move(data) : computer_move(data)
  data[:board][move] = data[:marker][player]
end

def other_player(player)
  player == :human ? :computer : :human
end

def play_game!(data)
  # Who goes first in each game depends on who played last in previous game
  until game_over? data
    system 'clear'
    display_board data
    move! data
    sleep 2 if data[:current_player] == :computer
    data[:current_player] = other_player data[:current_player]
  end
end

def play_match!(data)
  loop do
    init_player! data
    data[:board] = new_board data[:degree]
    system 'clear'
    display_board data
    play_game! data
    the_winner = game_status data
    puts '', message(FINAL_GAME_STATUS[the_winner])
    record_score! data, the_winner
    report_score data
    break if match_over? data
  end

  report_final_score data
end

def player_move(data)
  available_cells = empty_cells data
  available_numbers = joinor(available_cells)
  loop do
    puts '', message(:play_prompt, available: available_numbers)
    print '> '
    answer = gets.chomp.downcase
    exit 0 if answer == 'q'
    move = to_integer(answer)
    return move if available_cells.include?(move)
    puts message(:cell_not_available)
  end
end

#-----------------------------------------------------------------------------
# Miscellaneous methods

def message(symbol, args = {})
  format(MESSAGES[symbol], args)
end

def to_integer(value)
  Integer(value)
rescue ArgumentError
  nil
end

def joinor(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + "#{sep}#{final} #{list.last}"
end

degree = nil
loop do
  puts message(:get_board_degree)
  print '> '
  degree = to_integer(gets.chomp)
  break if degree && (3..9).include?(degree)
  puts message(:bad_board_degree)
end

puts message(:go_first)
print '> '
current_player = gets.chomp.downcase.start_with?('y') ? :human : :computer

# data[:board]           Hash indexed by cell number with marker symbol values
# data[:marker]          Hash indexed by player symbol that shows marker used
# data[:scores]          Games won by each player + tie games. a hash indexed by
#                        a player synbol
# data[:degree]          Degree of game (3-9)
# data[:current_player]  A player synbol
# data[:first_player]    Player that started this game
data = {
  scores:         new_scores,     # hash indexed by symbol
  degree:         degree,         # integer
  current_player: current_player
}

play_match! data
