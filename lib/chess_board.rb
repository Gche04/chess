require_relative './chess_pieces.rb'
require_relative './node.rb'

class Board
    def initialize
        @TURN = 0
        @castle_w = [1, 1, 1]
        @castle_b = [1, 1, 1]
        @board = DyNode.new
        @piece = Pieces.new
    end

    def set_board
        put_pieces("w")
        put_pieces("b")
    end

    def update_board
        print "   a  b  c  d  e  f  g  h "
        puts ""
        @board.print_y
        print "   a  b  c  d  e  f  g  h "
        puts ""
    end

    def move_pieces(n1, a1, n2, a2)
        move(n1, x1 = to_num(a1), n2, to_num(a2))
    end

    private

    def checkmate?(col1, col2)
        return true if king_capture?(col1, col2)
    end

    def king_capture?(col1, col2)
        if in_check?(col1, col2)
            return if king_can_move?(col2)
            
            arr = find_pieces(@piece.king_of(col2))
            checker_loc = in_check?(col1, col2)
            path = find_path(checker_loc[0], checker_loc[1], arr[0], arr[1])
            
            for y in (1..8) do
                for x in (1..8) do
                    ps = @board.get(y, x)
                    checker = @board.get(checker_loc[0], checker_loc[1])

                    if @piece.to_col(ps) == col2
                        if checker == "\u2658" || checker == "\u265E"
                            return if can_move_with_no_check?(y, x, checker_loc[0], checker_loc[1])
                        else
                            for locs in path do
                                return if can_move_with_no_check?(y, x, locs[0], locs[1])
                            end
                        end
                    end
                end
            end
            true
        end
    end

    def stale_mate?(col1, col2)
        return if checkmate?(col1, col2)
        return if in_check?(col1, col2)

        for y in (1..8) do
            for x in (1..8) do
                unless @board.get(y, x) == " " || @piece.to_col(@board.get(y, x)) == col1
                    return if piece_at_loc_can_move?(y, x)
                end
            end
        end
        true
    end

    def king_can_move?(col)
        arr = find_pieces(@piece.king_of(col))
        kg_moves_y = [-1, 1, 1, 1, 0, 0, -1, -1]
        kg_moves_x = [0, 0, 1, -1, -1, 1, -1, 1]

        for i in (0..7)
            y1 = arr[0]
            x1 = arr[1]
            y2 = y1 + kg_moves_y[i]
            x2 = x1 + kg_moves_x[i]

            if can_move_with_no_check?(y1, x1, y2, x2)
                return true
            end
        end
        return false
    end

    def piece_at_loc_can_move?(y1, x1)
        ps = @piece.to_name(@board.get(y1, x1))
        arr_y = []
        arr_x = []

        if ps == "qn" || ps == "kg"
            arr_y = [-1, 1, 1, 1, 0, 0, -1, -1]
            arr_x = [0, 0, 1, -1, -1, 1, -1, 1]

        elsif ps == "rk"
            arr_y = [-1, 1, 0, 0]
            arr_x = [0, 0, -1, 1]

        elsif ps == "bs"
            arr_y = [1, 1, -1, -1]
            arr_x = [1, -1, -1, 1]

        elsif ps == "kt"
            arr_y = [2, 1, -1, -2, -2, -1, 1, 2]
            arr_x = [1, 2, 2, 1, -1, -2, -2, -1]

        elsif ps == "pn"
            arr_y = [1, 1, 1, -1, -1, -1]
            arr_x = [0, 1, -1, 0, 1, -1]
        end

        for i in (0..arr_y.length() - 1)
            y2 = y1 + arr_y[i]
            x2 = x1 + arr_x[i]

            if can_move_with_no_check?(y1, x1, y2, x2)
                return true
            end
        end
        return false
    end

    def can_move_with_no_check?(y1, x1, y2, x2)
        c2 = @piece.to_col(@board.get(y1, x1))
        c1 = ""
        c2 == "w" ? c1 = "b" : c1 = "w"

        if can_move?(y1, x1, y2, x2)
            hold_nw_loc = @board.get(y2, x2)
            set_and_reset(y1, x1, y2, x2)
            if in_check?(c1, c2)
                set_and_reset(y2, x2, y1, x1)
                @board.set(y2, x2, hold_nw_loc)
                return
            end
            set_and_reset(y2, x2, y1, x1)
            @board.set(y2, x2, hold_nw_loc)
            return true
        end
    end

    def in_check?(col1, col2)
        kg = @piece.king_of(col2)
        arr = find_pieces(kg)
        
        for y in (1..8) do
            for x in (1..8) do
                official = @board.get(y, x)
                unless official == " "
                    if @piece.to_col(official) == col1
                        if can_move?(y, x, arr[0], arr[1])
                            return [y, x]
                        end
                    end
                end
            end
        end
        false
    end

    def not_moved?(x1, x2, c2)
        if c2 == "w"
            return if @castle_w[1] == 0
            return if x1 < x2 && @castle_w[2] == 0
            return if x1 > x2 && @castle_w[0] == 0
        else
            return if @castle_b[1] == 0
            return if x1 < x2 && @castle_b[2] == 0
            return if x1 > x2 && @castle_b[0] == 0
        end
        true
    end

    def turn?(col)
        if col == "w"
            return unless @TURN == 0
        else
            return unless @TURN == 1
        end
        true
    end

    def move(y1, x1, y2, x2)
        c2 = @piece.to_col(@board.get(y1, x1))
        c1 = ""
        c2 == "w" ? c1 = "b" : c1 = "w"
        hold_nw_loc = @board.get(y2, x2)

        return "illegal move" unless turn?(c2)

        if can_move?(y1, x1, y2, x2) == "castle"
            return "illegal move" unless not_moved?(x1, x2, c2)
            return "illegal move, check" if in_check?(c1, c2)
            return "illegal move" unless path_is_clear?(y1, x1, y2, x2)

            path = find_path(y1, x1, y2, x2)
            path << [y2, x2]
            path.shift

            for val in path do
                @piece.allow = true
                return "illegal move, check" unless can_move_with_no_check?(y1, x1, val[0], val[1])
                @piece.allow = false
            end

            x2 > x1 ? x2 -= 1 : x2 += 2
            set_and_reset(y1, x1, y2, x2)

            if x2 > x1
                x2 -= 1
                set_and_reset(y1, 8, y2, x2)
            else
                x2 += 1
                set_and_reset(y1, 1, y2, x2)
            end

        elsif can_move?(y1, x1, y2, x2)
            set_and_reset(y1, x1, y2, x2)

            if in_check?(c1, c2)
                set_and_reset(y2, x2, y1, x1)
                @board.set(y2, x2, hold_nw_loc)
                return "illegal move, check"
            end
        else
            return "illegal move"
        end

        if c2 == "w"
            @castle_w[2] = 0 unless @board.get(1, 8) == "\u2656"
            @castle_w[0] = 0 unless @board.get(1, 1) == "\u2656"
            @castle_w[1] = 0 unless @board.get(1, 5) == "\u2654"
        else
            @castle_b[2] = 0 unless @board.get(8, 8) == "\u265C"
            @castle_b[0] = 0 unless @board.get(8, 1) == "\u265C"
            @castle_b[1] = 0 unless @board.get(8, 5) == "\u265A"
        end


        if promotion?(y2, x2)
            color = promotion?(y2, x2)
            promote(y2, x2, color)
        end

        return "STALEMATE!" if stale_mate?(c2, c1)
        return "CHECKMATE!" if checkmate?(c2, c1)
        return "CHECK!" if in_check?(c2, c1)

        @TURN == 0 ? @TURN += 1 : @TURN -= 1
        return
    end

    def can_move?(y1, x1, y2, x2)
        if in_range?(y1, x1, y2, x2)
            loc = @board.get(y1, x1)
            new_loc = @board.get(y2, x2)
            answer = call(y1, x1, y2, x2)

            return true if answer == "allow"
            return "castle" if answer == "castle"
                
            if answer == "pawn diagonal" 
                return if @board.get(y2, x2) == " "
            elsif answer
                if loc_is_legal(new_loc, loc)
                    if loc == "\u265E" || loc == "\u2658"
                    elsif path_is_clear?(y1, x1, y2, x2)
                        if loc == "\u265F" || loc == "\u2659"
                            return unless new_loc == " "
                        end
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
            return true
        end
    end

    def promotion?(y2, x2)
        if @piece.to_name(@board.get(y2, x2)) == "pn"
            
            return unless y2 == 1 || y2 == 8
            return @piece.to_col(@board.get(y2, x2))
        end
    end

    def promote(y2, x2, color)
        puts "enter number to choose"
        if color == "w"
            print 1
            puts ". \u2655 \n"
            print 2
            puts ". \u2656 \n"
            print 3
            puts ". \u2657 \n"
            print 4
            puts ". \u2658 \n"

            pick = gets.chomp.to_i
            until pick.between?(1,4)
                puts "enter correct number, to choose"
                pick = gets.chomp.to_i
            end
            official = "\u2655" if pick == 1
            official = "\u2656" if pick == 2
            official = "\u2657" if pick == 3
            official = "\u2658" if pick == 4

            @board.set(y2, x2, official)
        else
            print 1
            puts ". \u265B \n"
            print 2
            puts ". \u265C \n"
            print 3
            puts ". \u265D \n"
            print 4
            puts ". \u265E \n"

            pick = gets.chomp.to_i
            until pick.between?(1,4)
                puts "enter correct number to choose"
                pick = gets.chomp.to_i
            end
            official = "\u265B" if pick == 1
            official = "\u265C" if pick == 2
            official = "\u265D" if pick == 3
            official = "\u265E" if pick == 4

            @board.set(y2, x2, official)
        end
    end

    def call(y1, x1, y2, x2)
        official = @board.get(y1, x1)
        if official == "\u265F" || official == "\u2659"
            return @piece.pawn_move(y1, x1, y2, x2, official)

        elsif official == "\u265E" || official == "\u2658"
            return @piece.knight_move(y1, x1, y2, x2)

        elsif official == "\u265D" || official == "\u2657"
            return @piece.bishop_move(y1, x1, y2, x2)

        elsif official == "\u265C" || official == "\u2656"
            return @piece.rook_move(y1, x1, y2, x2)

        elsif official == "\u265B" || official == "\u2655"
            return @piece.queen_move(y1, x1, y2, x2)

        elsif official == "\u265A" || official == "\u2654"
            return @piece.king_move(y1, x1, y2, x2)
        end
    end

    def loc_is_legal(new_l, old_l)
        return true if new_l == " "
        return true unless @piece.to_col(new_l) == @piece.to_col(old_l)
        false
    end

    def path_is_clear?(y1, x1, y2, x2)
        num1 = y1
        num2 = x1
        if y2 > y1
            num1 += 1
        elsif y2 < y1
            num1 -= 1
        end
        if x2 > x1
            num2 += 1
        elsif x2 < x1
            num2 -= 1
        end
        until num1 == y2 && num2 == x2
            return false unless @board.get(num1, num2) == " "
            if y2 > y1
                num1 += 1
            elsif y2 < y1
                num1 -= 1
            end
            if x2 > x1
                num2 += 1
            elsif x2 < x1
                num2 -= 1
            end
        end
        true
    end

    def in_range?(y1, x1, y2, x2)
        begin
            dy = (y1 - y2).abs
            dx = (x1 - x2).abs 
        
            y1 > y2 ? dy = y1 - dy : dy = y1 + dy
            x1 > x2 ? dx = x1 - dx : dx = x1 + dx
            return true if dy.between?(1,8) && dx.between?(1,8)
        rescue
            "Wrong input!!"
        end
    end

    def to_num(alpha)
        return 1 if alpha == 'a'
        return 2 if alpha == 'b'
        return 3 if alpha == 'c'
        return 4 if alpha == 'd'
        return 5 if alpha == 'e'
        return 6 if alpha == 'f'
        return 7 if alpha == 'g'
        return 8 if alpha == 'h'
    end

    def put_pieces(col)
        if col == "w"
            @board.set(1, 1, @piece.to_unicode(col, "rk"))
            @board.set(1, 2, @piece.to_unicode(col, "kt"))
            @board.set(1, 3, @piece.to_unicode(col, "bs"))
            @board.set(1, 4, @piece.to_unicode(col, "qn"))
            @board.set(1, 5, @piece.to_unicode(col, "kg"))
            @board.set(1, 6, @piece.to_unicode(col, "bs"))
            @board.set(1, 7, @piece.to_unicode(col, "kt"))
            @board.set(1, 8, @piece.to_unicode(col, "rk"))

            i = 1
            until i > 8
                @board.set(2, i, @piece.to_unicode(col, "pn"))
                i += 1
            end
        else
            @board.set(8, 1, @piece.to_unicode(col, "rk"))
            @board.set(8, 2, @piece.to_unicode(col, "kt"))
            @board.set(8, 3, @piece.to_unicode(col, "bs"))
            @board.set(8, 4, @piece.to_unicode(col, "qn"))
            @board.set(8, 5, @piece.to_unicode(col, "kg"))
            @board.set(8, 6, @piece.to_unicode(col, "bs"))
            @board.set(8, 7, @piece.to_unicode(col, "kt"))
            @board.set(8, 8, @piece.to_unicode(col, "rk"))

            i = 1
            until i > 8
                @board.set(7, i, @piece.to_unicode(col, "pn"))
                i += 1
            end
        end
    end

    def find_pieces(ps)
        arr = []
        y = 1
        while y < 9
            x = 1
            while x < 9
                if @board.get(y, x) == ps
                    arr << y
                    arr << x
                    return arr
                end
                x += 1
            end
            y += 1
        end
        arr
    end

    def find_path(y1, x1, y2, x2)
        arr = []
        aimer_y = y1
        aimer_x = x1

        until aimer_y == y2 && aimer_x == x2
            a = []
            a << aimer_y
            a << aimer_x
            arr << a

            if y1 > y2
                aimer_y -= 1
            elsif y1 < y2
                aimer_y += 1
            end
            if x1 > x2
                aimer_x -= 1
            elsif x1 < x2
                aimer_x += 1
            end
        end
        arr
    end

    def set_and_reset(y1, x1, y2, x2)
        @board.set(y2, x2, @board.get(y1, x1))
        @board.reset(y1, x1)
    end
end

def help_split(input)
    arr = input.split('')
    arr
end
