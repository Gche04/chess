
class XNode
    attr_accessor :x_val, :index, :child
    def initialize
        @x_val = "| |"
        @index = 1
        @child = nil
    end
end

class DxNode
    attr_accessor :dx
    def initialize
        @dx = build_x
    end

    def set_x(idx, psc, rt = @dx)
        return if rt == nil

        if rt.index == idx
            rt.x_val = "|#{psc}|"
            return
        end
        set_x(idx, psc, rt.child)
    end

    def get_x(idx, rt = @dx)
        return if rt == nil

        if rt.index == idx
            return rt.x_val
        end
        get_x(idx, rt.child)
    end

    def output(rt = @dx)
        return if rt == nil
        print rt.x_val
        output(rt.child)
    end

    private
    def build_x
        x = XNode.new
        xnod = x
        count = 1

        until count > 7
            xnod.index = count
            xnod.child = XNode.new
            xnod = xnod.child
            count += 1
        end
        xnod.index = count
        x
    end
end

class YNode
    attr_accessor :y_val, :count, :child
    def initialize
        @y_val = DxNode.new
        @count = 1
        @child = nil
    end
end

class DyNode
    attr_accessor :dy
    def initialize
        @dy = build_y
    end

    def set(y, x, psc)
        y_position = find(y)
        y_position.y_val.set_x(x, psc)
    end

    def get(y, x)
        begin
            y_position = find(y)
            y_position.y_val.get_x(x).delete "|"
        rescue
            "Wrong input!!"
        end
        
    end

    def reset(y, x)
        y_position = find(y)
        y_position.y_val.set_x(x, ' ')
    end

    def is_empty?(y, x)
        return true if get(y, x) == " "
        false
    end

    def find(count, rt = @dy)
        return if rt == nil
        return rt if rt.count == count
        find(count, rt.child)
    end

    def print_y(rt = @dy, count = 8)
        return if rt == nil
        print "#{count} "
        rt.y_val.output
        print " #{count}"
        puts ''
        print_y(rt.child, count -= 1)
    end

    private
    def build_y
        y = YNode.new
        ynod = y
        count = 8

        until count < 2
            ynod.count = count
            ynod.child = YNode.new
            ynod = ynod.child
            count -= 1
        end
        ynod.count = count
        y
    end
end
