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

WINNING_ROWS = %w(123 456 789 147 258 369 159 357)

def computer_move!(board)
  move = (rand(9) + 1).to_s until board[move] == ' '
  puts format(MESSAGES[:i_selected], move: move)
  board[move] = 'O'
end

def display(board)
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

def game_over?(board)
  winner(board) || tied_game(board)
end

# Returns X or O if one is a winner, T if a tie, nil if the game isn't over
def game_state(board)
  board.value?(' ') ? nil : '='
end

def initialize_board
  (1..9).map { |square| [square.to_s, ' '] }.to_h
end

def play
  board = initialize_board
  until game_over?(board)
    play_a_round! board
  end
  report_results board
end

def play_a_round!(board)
  system 'clear'
  display board
  player_move! board
  computer_move! board unless game_over? board
  sleep 2 unless game_over? board
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
  loop do
    puts MESSAGES[:play_prompt]
    print "> "
    move = gets.chomp
    break if board[move] == ' '
    puts MESSAGES[move.match(/^\d$/) ? :square_in_use : :invalid_square]
  end
  board[move] = 'X'
end

def report_results(board)
  results = if tied_game board
              :tie_game
            elsif winner(board) == 'X'
              :congratulations
            else
              :you_lost
            end
  puts MESSAGES[results]
end

# Returns X or O if row is all Xs or all Os, nil otherwise.
def three_in_a_row(board, row)
  squares = row.chars.map { |square| board[square] }
  return nil if squares[0] == ' '
  return nil unless squares[0] == squares[1] && squares[1] == squares[2]
  squares[0]
end

def tied_game(board)
  !board.value? ' '
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
