# Tic-Tac-Toe game
# Pete Hanson

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
TIE_GAME = 'T'

BOARD_SIZE = 3
WINNING_ROWS = %w(123 456 789 147 258 369 159 357)
WINNING_SCORE = 5

MESSAGES = {
  congratulations: 'You won. Congratulations!',
  continue:        'Press [Return] for next game, or type Q to quit.',
  i_selected:      'I selected square number %{move}',
  instructions:    "You are an #{PLAYER_MARKER}. " \
                   "The computer is an #{COMPUTER_MARKER}\n" \
                   'You may enter Q at any time to quit.',
  invalid_square:  'Invalid: that is the not the number of a square.',
  overall_loss:    'You lost %{#{COMPUTER_MARKER}} games to ' \
                   '%{#{PLAYER_MARKER}} with %{#{TIE_GAME} tie games. Sorry!',
  overall_tie:     'We tied at %{#{PLAYER_MARKER}} games to ' \
                   '%{#{COMPUTER_MARKER}} with %{#{TIE_GAME}} tie games.',
  overall_win:     'You won %{#{PLAYER_MARKER}} games to ' \
                   '%{#{COMPUTER_MARKER}} with %{#{TIE_GAME} tie games}. ' \
                   'Congratulations!',
  play_prompt:     'Please enter your move: %{available}',
  numbering:       "Squares are numbered as:\n\n",
  score:           'Overall scores:   you: %d   me: %d   ties: %d',
  square_in_use:   'That square is in use.',
  tie_game:        'Tie game. Sigh.',
  you_lost:        'Tic! Tac! Toe! You lost. Sorry!'
}

FINAL_GAME_STATUS = {
  PLAYER_MARKER   => MESSAGES[:congratulations],
  COMPUTER_MARKER => MESSAGES[:you_lost],
  TIE_GAME        => MESSAGES[:tie_game]
}

FINAL_MATCH_STATUS = {
  PLAYER_MARKER   => MESSAGES[:overall_win],
  COMPUTER_MARKER => MESSAGES[:overall_loss],
  TIE_GAME        => MESSAGES[:tieoverall_tie]
}

#-----------------------------------------------------------------------------
# Methods to manage board.

def display(board)
  system 'clear'
  puts MESSAGES[:instructions], ''
  (1..(BOARD_SIZE * BOARD_SIZE)).each_slice(BOARD_SIZE) do |row|
    display_row board, row
  end
end

def display_row(board, row)
  draw_line '-----', '+' unless row[0] == 1
  draw_line '     ', '|'
  row.each do |square|
    print '|' unless square % BOARD_SIZE == 1
    print "  #{board[square.to_s]}  "
  end
  puts ''
  draw_line '     ', '|'
end

def draw_line(horizontal, vertical)
  puts((horizontal + vertical) * (BOARD_SIZE - 1) + horizontal)
end

def initialize_board
  (1..9).map { |square| [square.to_s, INITIAL_MARKER] }.to_h
end

#-----------------------------------------------------------------------------
# Methods to manage game state

def empty_squares(board)
  board.select { |_, status| status == INITIAL_MARKER }.keys
end

def game_over?(board)
  winner(board) || tied_game?(board)
end

# Returns PLAYER_MARKER, COMPUTER_MARKER, TIE_GAME, or nil
def game_status(board)
  status = winner board
  return status if status
  return TIE_GAME if tied_game? board
  nil
end

def match_over?(scores)
  highest_score = scores.values_at(PLAYER_MARKER, COMPUTER_MARKER).max
  return true if highest_score >= WINNING_SCORE
  puts MESSAGES[:continue]
  print '> '
  gets.chomp.downcase == 'q'
end

def tied_game?(board)
  empty_squares(board).empty?
end

# Returns X if X has won the game, O if O has won the game, nil otherwise.
def winner(board)
  WINNING_ROWS.each do |row|
    squares = row.chars.map { |square| board[square] }
    if squares.count(PLAYER_MARKER) == 3
      return PLAYER_MARKER
    elsif squares.count(COMPUTER_MARKER) == 3
      return COMPUTER_MARKER
    end
  end
  nil
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
  puts format(FINAL_MATCH_STATUS[the_winner], scores)
end

def report_score(scores)
  the_scores = scores.values_at(PLAYER_MARKER, COMPUTER_MARKER, TIE_GAME)
  puts format(MESSAGES[:score], *the_scores)
end

#-----------------------------------------------------------------------------
# Methods to manage play

def computer_move!(board)
  move = empty_squares(board).sample
  puts format(MESSAGES[:i_selected], move: move)
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

def play_match
  scores = initialize_scores
  loop do
    board = initialize_board
    display board
    play_game! board
    the_winner = game_status board
    puts '', FINAL_GAME_STATUS[the_winner]
    record_score! scores, the_winner
    report_score scores
    break if match_over? scores
  end

  report_final_score scores
end

def player_move!(board)
  move = ''
  available_squares = empty_squares board
  available_numbers = joinor(available_squares)
  loop do
    puts '', format(MESSAGES[:play_prompt], available: available_numbers)
    show_numbers
    print "> "
    move = gets.chomp
    break if available_squares.include? move
    puts MESSAGES[move.match(/^\d$/) ? :square_in_use : :invalid_square]
  end
  board[move] = PLAYER_MARKER
end

#-----------------------------------------------------------------------------
# Miscellaneous methods

def joinor(list, sep = ', ', final = 'or')
  return list.join(sep) if list.size <= 1
  list[0, list.size - 1].join(sep) + "#{sep}#{final} #{list.last}"
end

def show_numbers
  format_string = (BOARD_SIZE <= 3) ? '%d' : '%2d'
  (1..(BOARD_SIZE * BOARD_SIZE)).each_slice(BOARD_SIZE).map do |row|
    puts "    #{row.map { |n| format(format_string, n) }.join ' '}"
  end
end

play_match
