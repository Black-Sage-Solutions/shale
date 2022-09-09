module Shale
  struct Gradient
    getter colour_xstep : Vector4(Float32)
    getter colour_ystep : Vector4(Float32)
    getter colours : StaticArray(Vector4(Float32), 3)

    def initialize(min : Vertex, mid : Vertex, max : Vertex)
      @colours = StaticArray[min.colour, mid.colour, max.colour]

      one_over_dx = 1_f32 / (
        ((mid.x - max.x) * (min.y - max.y)) - ((min.x - max.x) * (mid.y - max.y))
      )

      one_over_dy = -one_over_dx

      @colour_xstep = (
        ((colours[1] - colours[2]) * (min.y - max.y)) -
        ((@colours[0] - @colours[2]) * (mid.y - max.y))
      ) * one_over_dx

      @colour_ystep = (
        ((colours[1] - colours[2]) * (min.x - max.x)) -
        ((@colours[0] - @colours[2]) * (mid.x - max.x))
      ) * one_over_dy
    end
  end
end
