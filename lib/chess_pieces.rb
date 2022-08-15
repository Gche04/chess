
class Pieces
    attr_accessor :allow
    @allow = false

    def to_unicode(col, pcs)
        if col == "w"
            return "\u2654" if pcs == "kg"
            return "\u2655" if pcs == "qn"
            return "\u2656" if pcs == "rk"
            return "\u2657" if pcs == "bs"
            return "\u2658" if pcs == "kt"
            return "\u2659" if pcs == "pn"
            return nil
        end

        return "\u265A" if pcs == "kg"
        return "\u265B" if pcs == "qn"
        return "\u265C" if pcs == "rk"
        return "\u265D" if pcs == "bs"
        return "\u265E" if pcs == "kt"
        return "\u265F" if pcs == "pn"
        return nil
    end

    def king_of(col)
        return "\u2654" if col == "w"
        return "\u265A" if col == "b"
    end

    def pawn_move(y1, x1, y2, x2, col)
        if col == "\u2659"
            if y1 + 1 == y2
                return true if x1 == x2
                return "pawn diagonal" if x1 + 1 == x2 || x1 - 1 == x2
                return false
            elsif y1 == 2 && y2 == y1 + 2
                return true
            end
            return false
        end

        if y1 - 1 == y2
            return true if x1 == x2
            return "pawn diagonal" if x1 + 1 == x2 || x1 - 1 == x2
            return false
        elsif y1 == 7 && y2 == y1 - 2
            return true
        end
        false
    end

    def rook_move(y1, x1, y2, x2)
        return true if x1 == x2
        return true if y1 == y2
        false
    end

    def bishop_move(y1, x1, y2, x2)
        a = (y1 - y2).abs
        b = (x1 - x2).abs
        return true if a == b
        false
    end

    def queen_move(y1, x1, y2, x2)
        return true if x1 == x2
        return true if y1 == y2
        a = (y1 - y2).abs
        b = (x1 - x2).abs
        return true if a == b
        false
    end

    def king_move(y1, x1, y2, x2)
        if @allow
            if x1 == 5 && y1 == y2
                if x2 > x1 || x2 < x1 
                    return "allow"
                end
            end
        end

        if y1 == 1 || y1 == 8 && x1 == 5
            if y1 == y2
                if x2 == 8 || x2 == 1
                    return "castle"
                end
            end
        end
        
        if x1 == x2
            return true if (y1 - y2).abs == 1
        elsif y1 == y2
            return true if (x1 - x2).abs == 1
        elsif (y1 - y2).abs == (x1 - x2).abs
            return true if (y1 - y2).abs == 1
        end
        
        false
    end

    def knight_move(y1, x1, y2, x2)
        if (y1 - y2).abs == 2
            return true if (x1 - x2).abs == 1
        elsif (y1 - y2).abs == 1
            return true if (x1 - x2).abs == 2
        elsif(x1 - x2).abs == 2
            return true if (y1 - y2).abs == 1
        elsif(x1 - x2).abs == 1
            return true if (y1 - y2).abs == 2
        end
    end

    def to_col(uni)
        white_arr = ["\u2654", "\u2655", "\u2656", "\u2657", "\u2658", "\u2659"]
        black_arr = ["\u265A", "\u265B", "\u265C", "\u265D", "\u265E", "\u265F"]
        return "w" if white_arr.include?(uni)
        return "b" if black_arr.include?(uni)
    end

    def to_name(uni)
        return "qn" if uni == "\u2655" || uni == "\u265B"
        return "rk" if uni == "\u2656" || uni == "\u265C"
        return "bs" if uni == "\u2657" || uni == "\u265D"
        return "kt" if uni == "\u2658" || uni == "\u265E"
        return "pn" if uni == "\u2659" || uni == "\u265F"
        return "kg" if uni == "\u2654" || uni == "\u265A"
    end
end
