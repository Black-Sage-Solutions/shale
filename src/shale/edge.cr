module Shale
  class Edge
    @colour_step : Vector4(Float32)
    @x_step : Float32

    getter colour : Vector4(Float32)
    getter x : Float32
    getter y_end : UInt32
    getter y_start : UInt32

    def initialize(min : Vertex, max : Vertex, gradient : Gradient, min_y_index : Int)
      @y_end = max.y.ceil.to_u32
      @y_start = min.y.ceil.to_u32

      x_dist = max.x - min.x
      y_dist = max.y - min.y

      y_prestep = @y_start - min.y

      @x_step = x_dist / y_dist
      @x = min.x + y_prestep * @x_step

      x_prestep = @x - min.x

      @colour = (
        gradient.colours[min_y_index] +
        (gradient.colour_ystep * y_prestep) +
        (gradient.colour_xstep * x_prestep)
      )
      @colour_step = gradient.colour_ystep + (gradient.colour_xstep * @x_step)
    end

    def step : self
      @x += @x_step
      @colour = @colour + @colour_step
      self
    end
  end
end
