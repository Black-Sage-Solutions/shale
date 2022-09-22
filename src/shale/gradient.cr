module Shale
  struct Gradient
    # getter colour_xstep : Vector4(Float32)
    # getter colour_ystep : Vector4(Float32)
    # getter colours : StaticArray(Vector4(Float32), 3)
    getter one_over_z : StaticArray(Float32, 3) = StaticArray[0_f32, 0_f32, 0_f32]
    getter tex_coords_x : StaticArray(Float32, 3) = StaticArray[0_f32, 0_f32, 0_f32]
    getter tex_coords_y : StaticArray(Float32, 3) = StaticArray[0_f32, 0_f32, 0_f32]

    getter one_over_zx_step : Float32
    getter one_over_zy_step : Float32
    getter tex_coords_xx_step : Float32
    getter tex_coords_xy_step : Float32
    getter tex_coords_yx_step : Float32
    getter tex_coords_yy_step : Float32

    def initialize(min : Vertex, mid : Vertex, max : Vertex)
      one_over_dx = 1_f32 / (
        ((mid.x - max.x) * (min.y - max.y)) - ((min.x - max.x) * (mid.y - max.y))
      )

      one_over_dy = -one_over_dx

      # The `Vertex#w` attr is used for the perspective Z value
      @one_over_z[0] = 1_f32 / min.w
      @one_over_z[1] = 1_f32 / mid.w
      @one_over_z[2] = 1_f32 / max.w

      @tex_coords_x[0] = min.tex_coords.x * @one_over_z[0]
      @tex_coords_x[1] = mid.tex_coords.x * @one_over_z[1]
      @tex_coords_x[2] = max.tex_coords.x * @one_over_z[2]

      @tex_coords_y[0] = min.tex_coords.y * @one_over_z[0]
      @tex_coords_y[1] = mid.tex_coords.y * @one_over_z[1]
      @tex_coords_y[2] = max.tex_coords.y * @one_over_z[2]

      @tex_coords_xx_step = calc_step @tex_coords_x, min.y, mid.y, max.y, one_over_dx
      @tex_coords_xy_step = calc_step @tex_coords_x, min.x, mid.x, max.x, one_over_dy
      @tex_coords_yx_step = calc_step @tex_coords_y, min.y, mid.y, max.y, one_over_dx
      @tex_coords_yy_step = calc_step @tex_coords_y, min.x, mid.x, max.x, one_over_dy
      @one_over_zx_step = calc_step @one_over_z, min.y, mid.y, max.y, one_over_dx
      @one_over_zy_step = calc_step @one_over_z, min.x, mid.x, max.x, one_over_dy

      # @colours = StaticArray[min.colour, mid.colour, max.colour]
      # @colour_xstep = calc_step @colours, min.y, mid.y, max.y, one_over_dx
      # @colour_ystep = calc_step @colours, min.x, mid.x, max.x, one_over_dy
    end

    # Calculate the step value
    #
    # ### Description
    private def calc_step(coords : Indexable(Float32), min_axis : Float32, mid_axis : Float32, max_axis : Float32, one_over_d : Float32) : Float32
      (
        ((coords[1] - coords[2]) * (min_axis - max_axis)) -
          ((coords[0] - coords[2]) * (mid_axis - max_axis))
      ) * one_over_d
    end
  end
end
