module Shale
  alias Line = {y: UInt32, begin: UInt32, end: UInt32}

  class RenderCtx
    # In the future, would be nice to set an array with range type
    @data : Array(Line)

    def initialize
      @data = Array(Line).new
    end

    def draw(target : Shale::Surface)
      @data.each do |line|
        y = line[:y]

        (line[:begin]..line[:end]).each do |x|
          target.map_pixel x, y, 0xff, 0xff, 0xff
        end
      end
    end

    def set_point(y : UInt32, x_begin : UInt32, x_end : UInt32)
      @data << {y: y, begin: x_begin, end: x_end}
    end
  end
end
