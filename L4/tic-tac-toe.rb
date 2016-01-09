# Tic-Tac-Toe game
# Pete Hanson

def display(board)
  puts <<-EOS
         |     |
      #{board[1]}  |  #{board[2]}  |  #{board[3]}
         |     |
    -----+-----+------
         |     |
      #{board[4]}  |  #{board[5]}  |  #{board[6]}
         |     |
    -----+-----+------
         |     |
      #{board[7]}  |  #{board[8]}  |  #{board[9]}
         |     |
EOS
end

def initialize_board
  (1..9).map { |square| [square, ' '] }.to_h
end

def play
  board = initialize_board
  play_a_round board
end

def play_a_round(board)
  display board
end

play
