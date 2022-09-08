module Shale
  class Edge
    @x_step : Float32

    getter x : Float32
    getter y_end : UInt32
    getter y_start : UInt32

    def initialize(min : Shale::Vertex, max : Shale::Vertex)
      @y_end = max.y.ceil.to_u32
      @y_start = min.y.ceil.to_u32

      x_dist = max.x - min.x
      y_dist = max.y - min.y

      @x_step = x_dist / y_dist
      @x = min.x + (@y_start - min.y) * @x_step
    end

    def step : self
      @x += @x_step
      self
    end
  end
end
