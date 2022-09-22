module Shale
  class Edge
    # @colour_step : Vector4(Float32)
    @x_step : Float32

    getter one_over_z : Float32
    getter one_over_z_step : Float32
    getter tex_coords_x : Float32
    getter tex_coords_x_step : Float32
    getter tex_coords_y : Float32
    getter tex_coords_y_step : Float32

    # getter colour : Vector4(Float32)
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

      # @colour = (
      #   gradient.colours[min_y_index] +
      #   (gradient.colour_ystep * y_prestep) +
      #   (gradient.colour_xstep * x_prestep)
      # )
      # @colour_step = gradient.colour_ystep + (gradient.colour_xstep * @x_step)

      @tex_coords_x = (
        gradient.tex_coords_x[min_y_index] +
        gradient.tex_coords_xx_step * x_prestep +
        gradient.tex_coords_xy_step * y_prestep
      )
      @tex_coords_x_step = gradient.tex_coords_xy_step + gradient.tex_coords_xx_step * @x_step

      @tex_coords_y = (
        gradient.tex_coords_y[min_y_index] +
        gradient.tex_coords_yx_step * x_prestep +
        gradient.tex_coords_yy_step * y_prestep
      )
      @tex_coords_y_step = gradient.tex_coords_yy_step + gradient.tex_coords_yx_step * @x_step

      # This is part of the linear equation for perspective mapping (1/z)
      @one_over_z = (
        gradient.one_over_z[min_y_index] +
        gradient.one_over_zx_step * x_prestep +
        gradient.one_over_zy_step * y_prestep
      )
      @one_over_z_step = gradient.one_over_zy_step + gradient.one_over_zx_step * @x_step
    end

    def step : self
      # @colour += @colour_step
      @one_over_z += @one_over_z_step
      @tex_coords_x += @tex_coords_x_step
      @tex_coords_y += @tex_coords_y_step
      @x += @x_step
      self
    end
  end
end
