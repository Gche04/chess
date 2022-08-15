require_relative './chess_board.rb'

chess_board = Board.new
chess_board.set_board
chess_board.update_board
puts ""

result = ""

while true
    puts "enter current location e.g '2a' "
    loc = gets.chomp
    puts ""
    old_loc = help_split(loc)

    puts  "enter location to move to e.g '3a' "
    loc = gets.chomp
    puts ""
    new_loc = help_split(loc)

    result = chess_board.move_pieces(old_loc[0].to_i, old_loc[1], new_loc[0].to_i, new_loc[1])
    puts result
    chess_board.update_board
    puts ""

    break if result == "STALEMATE!"
    break if result == "CHECKMATE!"
end
