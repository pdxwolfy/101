# Tic-Tac-Toe game
# Pete Hanson

INITIAL_MARKER = ' '
PLAYER_MARKER = :X
COMPUTER_MARKER = :O
THE_PLAYERS = [PLAYER_MARKER, COMPUTER_MARKER]
TIE_GAME = :T
WINNING_SCORE = 5

MESSAGES = {
  bad_board_magnitude:  'Board size should be between 3 and 9, inclusive.',
  cell_not_available:   'That square is either not available or invalid.',
  congratulations:      'You won. Congratulations!',
  continue:             'Press [Return] for next game, or type Q to quit.',
  get_board_magnitude:  'What size board do you want (3-9)?',
  i_selected:           'I selected square number %{move}',
  instructions:         "You are an #{PLAYER_MARKER}. " \
                        "The computer is an #{COMPUTER_MARKER}\n" \
                        'You may enter Q at any time to quit.',
  overall_loss:         "You lost %{#{COMPUTER_MARKER}} games to " \
                        "%{#{PLAYER_MARKER}} with %{#{TIE_GAME}} " \
                        'tie games. Sorry!',
  overall_tie:          "We tied at %{#{PLAYER_MARKER}} games to " \
                        "%{#{COMPUTER_MARKER}} with %{#{TIE_GAME}} " \
                        'tie games.',
  overall_win:          "You won %{#{PLAYER_MARKER}} games to " \
                        "%{#{COMPUTER_MARKER}} with %{#{TIE_GAME}} " \
                        'tie games. Congratulations!',
  play_prompt:          'Please enter your move: %{available}',
  numbering:            "Squares are numbered as:\n\n",
  score:                "Overall scores:   you: %{#{PLAYER_MARKER}}   " \
                        "me: %{#{COMPUTER_MARKER}}   ties: %{#{TIE_GAME}}",
  tie_game:             'Tie game. Sigh.',
  you_lost:             'Tic! Tac! Toe! You lost. Sorry!'
}

FINAL_GAME_STATUS = {
  PLAYER_MARKER   => :congratulations,
  COMPUTER_MARKER => :you_lost,
  TIE_GAME        => :tie_game
}

FINAL_MATCH_STATUS = {
  PLAYER_MARKER   => :overall_win,
  COMPUTER_MARKER => :overall_loss,
  TIE_GAME        => :overall_tie
}

#-----------------------------------------------------------------------------
# Methods to manage board and movement key

def board_magnitude(board)
  (Math.sqrt(board.size) + 0.0001).to_i
end

def display(board)
  system 'clear'
  puts message(:instructions), ''
  ncells = board_magnitude board
  out = '---+' * (ncells - 1) + '---'
  (1..board.size).each_slice(ncells) do |row|
    puts "#{out}      #{out}" unless row[0] == 1
    display_row board, row
  end
end

def display_row(board, row)
  print [row.map { |cell| " #{board[cell]} " }].join('|')
  print '      '
  puts [row.map { |cell| format(' %-2s', cell) }].join('|')
end

def initialize_board(magnitude)
  Hash[(1..(magnitude * magnitude)).map { |n| [n, INITIAL_MARKER] }]
end

#-----------------------------------------------------------------------------
# Methods to manage/determine game state

def empty_cells(board)
  board.select { |_, status| status == INITIAL_MARKER }.keys
end

def game_over?(board)
  winner(board) || tied_game?(board)
end

def game_status(board)
  status = winner board
  if status
    status
  elsif tied_game? board
    TIE_GAME
  end
end

def match_over?(scores)
  return true if scores.values_at(*THE_PLAYERS).max >= WINNING_SCORE
  puts message(:continue)
  print '> '
  gets.chomp.downcase == 'q'
end

def tied_game?(board)
  empty_cells(board).empty?
end

def winner(board)
  magnitude = board_magnitude board
  winning_lines(board, magnitude).each do |line|
    cells = line.map { |cell| board[cell] }
    the_winner = THE_PLAYERS.find { |player| cells.count(player) == magnitude }
    return the_winner if the_winner
  end
  nil
end

def winning_columns(board, magnitude)
  (1..magnitude).map { |n| (n..board.size).step(magnitude).to_a }
end

def winning_diagonals(board, magnitude)
  diag1 = (1..board.size).step(magnitude + 1).to_a
  diag2 = (magnitude..board.size - 1).step(magnitude - 1).to_a
  [diag1, diag2]
end

def winning_lines(board, magnitude)
  winning_rows(board, magnitude) +
    winning_columns(board, magnitude) +
    winning_diagonals(board, magnitude)
end

def winning_rows(board, magnitude)
  (1..board.size).each_slice(magnitude).to_a
end

#-----------------------------------------------------------------------------
# Methods used to manage and report scoring

def initialize_scores
  { PLAYER_MARKER => 0, COMPUTER_MARKER => 0, TIE_GAME => 0 }
end

def record_score!(scores, the_winner)
  scores[the_winner] += 1
end

def report_final_score(scores)
  the_winner = if scores[PLAYER_MARKER] > scores[COMPUTER_MARKER]
                 PLAYER_MARKER
               elsif scores[PLAYER_MARKER] < scores[COMPUTER_MARKER]
                 COMPUTER_MARKER
               else
                 TIE_GAME
               end
  puts message(FINAL_MATCH_STATUS[the_winner], scores)
end

def report_score(scores)
  puts message(:score, scores)
end

#-----------------------------------------------------------------------------
# Methods to manage play

def choose_move(board)
  empty_cells(board).sample
end

def computer_move!(board)
  move = choose_move(board)
  puts message(:i_selected, move: move)
  board[move] = COMPUTER_MARKER
end

def play_game!(board)
  until game_over? board
    display board
    player_move! board
    computer_move! board unless game_over? board
    sleep 2
  end
end

def play_match(board_magnitude)
  scores = initialize_scores
  loop do
    board = initialize_board board_magnitude
    display board
    play_game! board
    the_winner = game_status board
    puts '', message(FINAL_GAME_STATUS[the_winner])
    record_score! scores, the_winner
    report_score scores
    break if match_over? scores
  end

  report_final_score scores
end

def player_move!(board)
  available_cells = empty_cells board
  available_numbers = joinor(available_cells)
  loop do
    puts '', message(:play_prompt, available: available_numbers)
    print "> "
    move = to_integer(gets.chomp)
    if available_cells.include?(move)
      board[move] = PLAYER_MARKER
      break
    end
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

board_magnitude = nil
loop do
  puts message(:get_board_magnitude)
  board_magnitude = to_integer(gets.chomp)
  break if board_magnitude && (3..10).include?(board_magnitude)
  puts message(:bad_board_magnitude)
end

play_match board_magnitude
