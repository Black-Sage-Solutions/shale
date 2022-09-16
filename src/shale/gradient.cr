module Shale
  struct Gradient
    # getter colour_xstep : Vector4(Float32)
    # getter colour_ystep : Vector4(Float32)
    # getter colours : StaticArray(Vector4(Float32), 3)

    getter tex_coords_x : StaticArray(Float32, 3) = StaticArray[0_f32, 0_f32, 0_f32]
    getter tex_coords_y : StaticArray(Float32, 3) = StaticArray[0_f32, 0_f32, 0_f32]

    getter tex_coords_xx_step : Float32
    getter tex_coords_xy_step : Float32
    getter tex_coords_yx_step : Float32
    getter tex_coords_yy_step : Float32

    def initialize(min : Vertex, mid : Vertex, max : Vertex)
      one_over_dx = 1_f32 / (
        ((mid.x - max.x) * (min.y - max.y)) - ((min.x - max.x) * (mid.y - max.y))
      )

      one_over_dy = -one_over_dx

      @tex_coords_x[0] = min.tex_coords.x
      @tex_coords_x[1] = mid.tex_coords.x
      @tex_coords_x[2] = max.tex_coords.x

      @tex_coords_y[0] = min.tex_coords.y
      @tex_coords_y[1] = mid.tex_coords.y
      @tex_coords_y[2] = max.tex_coords.y

      @tex_coords_xx_step = (
        ((@tex_coords_x[1] - @tex_coords_x[2]) * (min.y - max.y)) -
        ((@tex_coords_x[0] - @tex_coords_x[2]) * (mid.y - max.y))
      ) * one_over_dx

      @tex_coords_xy_step = (
        ((@tex_coords_x[1] - @tex_coords_x[2]) * (min.x - max.x)) -
        ((@tex_coords_x[0] - @tex_coords_x[2]) * (mid.x - max.x))
      ) * one_over_dy

      @tex_coords_yx_step = (
        ((@tex_coords_y[1] - @tex_coords_y[2]) * (min.y - max.y)) -
        ((@tex_coords_y[0] - @tex_coords_y[2]) * (mid.y - max.y))
      ) * one_over_dx

      @tex_coords_yy_step = (
        ((@tex_coords_y[1] - @tex_coords_y[2]) * (min.x - max.x)) -
        ((@tex_coords_y[0] - @tex_coords_y[2]) * (mid.x - max.x))
      ) * one_over_dy

      # @colours = StaticArray[min.colour, mid.colour, max.colour]
      # @colour_xstep = (
      #   ((@colours[1] - @colours[2]) * (min.y - max.y)) -
      #   ((@colours[0] - @colours[2]) * (mid.y - max.y))
      # ) * one_over_dx

      # @colour_ystep = (
      #   ((@colours[1] - @colours[2]) * (min.x - max.x)) -
      #   ((@colours[0] - @colours[2]) * (mid.x - max.x))
      # ) * one_over_dy
    end
  end
end
