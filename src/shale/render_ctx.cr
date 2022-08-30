module Shale
  class RenderCtx
    @data : Array(UInt32)

    def initialize(@height : UInt32)
      @data = Array(UInt32).new @height * 2, 0_u32
    end

    def draw(target : Shale::Surface, y_min : UInt32, y_max : UInt32)
      (y_min...y_max).each do |y|
        y_index = y * 2
        x_begin, x_end = @data[y_index, y_index + 1]
        (x_begin...x_end).each do |x|
          target.map_pixel x, y, 0xff, 0xff, 0xff, 0xff
        end
      end
    end

    def scan_to_triangle(min : Shale::Vertex, mid : Shale::Vertex, max : Shale::Vertex, which_hand : Int32)
      self.scan_to_line(min, max, 0 + which_hand)
      self.scan_to_line(min, mid, 1 - which_hand)
      self.scan_to_line(mid, max, 1 - which_hand)
    end

    def scan_to_line(min : Shale::Vertex, max : Shale::Vertex, which_hand : Int32)
      x_dist = max[:x] - min[:x]
      y_dist = max[:y] - min[:y]

      return if y_dist.to_i <= 0

      x_step = x_dist / y_dist
      current_x = min[:x]

      (min[:y].to_u32...max[:y].to_u32).each do |y|
        @data[y * 2 + which_hand] = current_x.to_u32
        current_x += x_step
      end
    end

    def set(y : UInt32, x_begin : UInt32, x_end : UInt32)
      @data[y * 2] = x_begin
      @data[y * 2 + 1] = x_end
    end
  end
end
