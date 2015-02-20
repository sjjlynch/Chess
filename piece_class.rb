class Piece

  DIAG_SHIFTS = [[-1, 1], [1, 1], [1, -1], [-1, -1]]
  ORTH_SHIFTS = [[0, 1], [0, -1], [1, 0], [-1, 0]]
  # when refactoring, create a hash for symbol values and unicode keys
  attr_accessor :pos, :board
  attr_reader :color, :symbol

  def initialize(pos, color, board)
    @pos = pos
    @color = color
    @board = board
  end

  def inspect
    {:pos => pos,
      :color => color,
      :symbol => symbol}.inspect
  end

  def valid_moves
    move_array = moves.select do |move|
      !move_into_check?(move)
    end
    move_array
  end

  def move_into_check?(move)
    duped_board = self.board.dup
    duped_board.move!(self.pos, move)
    duped_board.in_check?(self.color)
  end
end


class SlidingPiece < Piece

  def moves
    poss_moves = []
    shifts.each do |direction|    # each direction of the shifts
      1.upto(7) do |mult|         # multiples of that direction
        offset = direction[0] * mult, direction[1] * mult
        poss_move = [self.pos[0] + offset[0], self.pos[1] + offset[1]]
        if @board.on_board?(poss_move)    # off the board?
          maybe_piece = @board[poss_move]
          if maybe_piece.nil?   # empty space?
            poss_moves << poss_move
          else
            if maybe_piece.color != self.color  # enemy piece, go there.
              poss_moves << poss_move
            end                               # otherwise, friendly piece
            break                             # either way, stop the loop in that direction
          end
        else
          break
        end
      end
    end
    poss_moves
  end

end

class SteppingPiece < Piece

  def moves
  [].tap do |poss_moves|
    # until the board is done, friendly piece is reached, or enemy piece (plus piece) is reached
    # need to multiply shift values
    shifts.each do |direction|    # each direction of the shifts
      poss_move = [self.pos[0] + direction[0], self.pos[1] + direction[1]]
      if @board.on_board?(poss_move)    # off the board?
        maybe_piece = @board[poss_move]
        if maybe_piece.nil?   # empty space?
          poss_moves << poss_move
        else
          if maybe_piece.color != self.color  # enemy piece, go there.
            poss_moves << poss_move
          end                               # otherwise, friendly piece
        end
      end
    end
  end
end


end

class Rook < SlidingPiece
  def symbol
    self.color == :black ? @symbol = "\u265C" : @symbol = "\u2656"
  end
  #shifts method which returns the array of all shifts
  def shifts
    ORTH_SHIFTS
  end

end

class Knight < SteppingPiece
  CIRCLE = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2] ]


  def symbol
    self.color == :black ? @symbol = "\u265E" : @symbol = "\u2658"
  end

  def shifts
    CIRCLE
  end

end

class Bishop < SlidingPiece

  def symbol
    self.color == :black ? @symbol = "\u265D" : @symbol = "\u2657"
  end

  def shifts
    DIAG_SHIFTS
  end

end

class Queen < SlidingPiece

  def symbol
    self.color == :black ? @symbol = "\u265B" : @symbol = "\u2655"
  end

  def shifts
    ORTH_SHIFTS + DIAG_SHIFTS
  end
end

class King < SteppingPiece

  def symbol
    self.color == :black ? @symbol = "\u265A" : @symbol = "\u2654"
  end

  def shifts
    ORTH_SHIFTS + DIAG_SHIFTS
  end
end

class Pawn < Piece
  DIAGS = [[-1, 1], [-1, -1]]

  def symbol
    self.color == :black ? @symbol = "\u265F" : @symbol = "\u2659"
  end

  def starting_row
    color == :white ? 6 : 1
  end

  def moves
    self.color == :white ? i = 1 : i = -1

    forward_1 = [-1, 0]
    forward_2 = [-2, 0]

    all_moves = []

    all_moves << forward_1
    all_moves << forward_2 if pos[0] == starting_row
    all_moves.map! { |move| [pos[0] + move[0] * i, pos[1] + move[1]] }
    all_moves.reject! { |move| !board.on_board?(move) || !board[move].nil? }

    diag_moves = DIAGS.map do |move|
      [pos[0] + move[0] * i, pos[1] + move[1]]
    end

    diag_moves.reject! do |move|
      !board.on_board?(move) ||
        board[move].nil? ||
        board[move].color == color
    end

    all_moves + diag_moves

  end

end
