require_relative 'piece_class.rb'
require_relative 'colorize'

class InvalidMove < ArgumentError
end

class CheckMate <ArgumentError
end

class Board

  attr_accessor :board

  def initialize(with_pieces = true)
    @board = Array.new(8) {Array.new(8) }
    set_pieces if with_pieces
  end

  PIECES_POS = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

  def set_pieces
    board[0], board[7] = PIECES_POS, PIECES_POS.dup
    board[1].map!.with_index {|_, i| Pawn.new([1, i], :black, self ) }
    board[6].map!.with_index {|_, i| Pawn.new([6, i], :white, self ) }
    board[0].map!.with_index {|klass, i| klass.new([0, i], :black, self) }
    board[7].map!.with_index {|klass, i| klass.new([7, i], :white, self) }
    board
  end

  def create_piece(x,y)
    board[x][y] = King.new([x, y], :black , self)
  end

  def on_board?(pos)
    pos.all? { |coord| (0..7).cover?(coord) }
  end

  def []=(pos, val)
    row, col = pos
    board[row][col] = val
  end

  def [](pos)
    row, col = pos
    board[row][col]
  end

  def render
    board.map do |row|
      row.map do |square|
        if square.nil?
          "\u25A2"
        else
          square.symbol
        end
      end * " "
    end * "\n"
  end

  def in_check?(col)
    king_pos = self.pieces.find do |piece|
      piece.class == King && piece.color == col
    end.pos
    entire_color(other_color(col)).any? { |piece| piece.moves.include?(king_pos) }
  end

  def pieces
    board.flatten.compact
  end

  def other_color color
    color == :black ?  :white : :black
  end

  def entire_color color
    pieces.select{ |piece| piece.color == color }
  end

  def dup
    duped_board = Board.new(false)
    pieces.each do |piece|
      duped_board[piece.pos] = piece.class.new(piece.pos, piece.color, duped_board )
    end
    duped_board
  end

  def move!(start_pos, end_pos)
    piece = self[start_pos]
    piece.pos = end_pos
    self[end_pos] = piece
    self[start_pos] = nil
  end

  def move(start, end_pos, color)
    # begin
      raise InvalidMove.new "NO PIECE THERE!" if self[start].nil?
      piece = self[start]

      raise InvalidMove.new puts "NOT YOUR PIECE! CHOOSE AGAIN!" unless self[start].color == color

      unless piece.valid_moves.include? end_pos
        raise InvalidMove.new "You're in check!"
      end

      if checkmate?(color)
        raise CheckMate.new "You lose. Checkmate."
      end
      move!(start, end_pos)
  end

  def checkmate?(col)
    entire_color(col).all? { |piece| piece.valid_moves.empty? }
  end

end

class HumanPlayer

  attr_reader :color

    def initialize(color, game_board)
      @color = color
      @game_board = game_board
    end

    def play_turn
      begin
        puts "\n"
        puts @game_board.render
        puts "#{color}".capitalize + "\'s turn."
        puts "Coords of piece you want to move?"
          move_from = gets.chomp.split("")
          x1, y1 = move_from[0].to_i, move_from[1].to_i
        puts "Coords of position you want to move to?"
          move_to = gets.chomp.split("")
          x2, y2 = move_to[0].to_i, move_to[1].to_i
        @game_board.move([x1, y1], [x2, y2], self.color)

      rescue InvalidMove
      retry
      end
    end

end

class Game

  attr_accessor :game_board, :player_1, :player_2

  def initialize
    @game_board = Board.new
    @player_1 = HumanPlayer.new(:white, @game_board)
    @player_2 = HumanPlayer.new(:black, @game_board)
    play
  end

  def play
    until @game_board.checkmate?(:white) || @game_board.checkmate?(:black) do
      player_1.play_turn

      player_2.play_turn
    end
  end

end



g = Game.new
g.play
