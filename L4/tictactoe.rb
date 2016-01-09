# Tic-Tac-Toe game
# Pete Hanson

MESSAGES = {
  congratulations: 'You won. Congratulations!',
  i_selected:      'I selected square number %{move}',
  invalid_square:  'Invalid: that is the not the number of a square.',
  play_prompt:
    "                                                       1 2 3\n" \
    "Please enter your move (1-9). Squares are numbered as: 4 5 6\n" \
    "                                                       7 8 9",
  square_in_use:   'That square is in use.',
  tie_game:        'Tie game. Sigh.',
  you_lost:        'Tic! Tac! Toe! You lost. Sorry!'
}

STATES = { 'X' => :congratulations, 'O' => :you_lost, 'T' => :tie_game }
WINNING_ROWS = %w(123 456 789 147 258 369 159 357)

def computer_move!(board)
  move = (rand(9) + 1).to_s until board[move] == ' '
  puts format(MESSAGES[:i_selected], move: move)
  board[move] = 'O'
end

def display(board)
  system 'clear'
  puts <<-EOS
         |     |
      #{board['1']}  |  #{board['2']}  |  #{board['3']}
         |     |
    -----+-----+------
         |     |
      #{board['4']}  |  #{board['5']}  |  #{board['6']}
         |     |
    -----+-----+------
         |     |
      #{board['7']}  |  #{board['8']}  |  #{board['9']}
         |     |
EOS
end

def empty_squares(board)
  board.select { |_, state| state == ' ' }
end

def game_over?(board)
  winner(board) || tied_game(board)
end

def initialize_board
  (1..9).map { |square| [square.to_s, ' '] }.to_h
end

def play
  board = initialize_board
  state = play_a_round! board while state.nil?
  display board
  puts '', MESSAGES[STATES[state]]
end

# Returns game state (X, O, T, nil)
def play_a_round!(board)
  display board
  player_move! board
  computer_move! board unless game_over? board
  sleep 2
  return nil unless game_over? board
  return 'T' if tied_game board
  winner board
end

def play_again?
  puts "\n\n"
  puts "Play another game (Y for Yes)?"
  print "> "
  answer = gets.chomp.downcase
  answer.start_with? 'y'
end

def player_move!(board)
  move = ''
  available_squares = empty_squares board
  loop do
    puts MESSAGES[:play_prompt]
    print "> "
    move = gets.chomp
    break if available_squares.key? move
    puts MESSAGES[move.match(/^\d$/) ? :square_in_use : :invalid_square]
  end
  board[move] = 'X'
end

# Returns X or O if row is all Xs or all Os, nil otherwise.
def three_in_a_row(board, row)
  squares = row.chars.map { |square| board[square] }
  return nil if squares[0] == ' '
  return nil unless squares[0] == squares[1] && squares[1] == squares[2]
  squares[0]
end

def tied_game(board)
  empty_squares(board).size == 0
end

# Returns X if X has won the game, O if O has won the game, nil otherwise.
def winner(board)
  WINNING_ROWS.each do |row|
    state = three_in_a_row(board, row)
    return state if state
  end
  nil
end

loop do
  play
  break unless play_again?
end
