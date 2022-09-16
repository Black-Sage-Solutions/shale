module Shale
  class RenderCtx
    # Render Context
    #
    # ### Description
    #
    # For now to save time and getting things working, just following the implementation
    # from the video series, in the future (depending on where this class' goes), would be good to change:
    #
    # * Not relying on the 'window' dimensions for the size of @data
    # * Conform on which type of Int?
    # * remove width and height and just use @target's width and height instead
    #
    def initialize(@width : Int32, @height : Int32, @target : Shale::Surface)
    end

    def draw_scan_line(left : Shale::Edge, right : Shale::Edge, y : UInt32, gradient : Gradient, texture : Shale::Surface)
      x_min = left.x.ceil.to_u32
      x_max = right.x.ceil.to_u32

      x_prestep = x_min - left.x

      tex_coords_x = left.tex_coords_x + (gradient.tex_coords_xx_step * x_prestep)
      tex_coords_y = left.tex_coords_y + (gradient.tex_coords_yx_step * x_prestep)

      # colour = gradient.colour_xstep * x_prestep + left.colour

      (x_min...x_max).each do |x|
        # This calculation for the colour channel values seem rather inaccurate
        # to get a UInt8 value from the vector calc
        # could only use .to_u8! but values beyond UInt8 are undefined behaviour
        # r = (colour.x * 255 + 0.5).to_u8! # .floor.clamp(0, 255).to_u8
        # g = (colour.y * 255 + 0.5).to_u8! # .floor.clamp(0, 255).to_u8
        # b = (colour.z * 255 + 0.5).to_u8! # .floor.clamp(0, 255).to_u8
        # @target.map_pixel x, y, b, g, r, 0xff
        # colour = colour + gradient.colour_xstep

        src_x = (tex_coords_x * (texture.width - 1) + 0.5_f32).to_i
        src_y = (tex_coords_y * (texture.height - 1) + 0.5_f32).to_i

        @target.copy_pixel x, y, src_x, src_y, texture

        tex_coords_x += gradient.tex_coords_xx_step
        tex_coords_y += gradient.tex_coords_yx_step
      end
    end

    def draw_triangle(*vertices : Shale::Vertex, texture : Shale::Surface)
      case vertices.size
      when .> 3
        raise "Too many vertices: (#{vertices.size})"
      when .< 3
        raise "Too few vertices: (#{vertices.size})"
      end

      screen_space_tf = Shale::Matrix4(Float32).new.identity.ss_transform (@width / 2).to_f32, (@height / 2).to_f32

      tf_verts = vertices.map &.transform(screen_space_tf).perspec_divide

      # In the video, the sorting happens manaully, checking each point individually and mapping to a respective var name,
      # i'm wondering if it's much faster than just doing a simple sort of an array
      min, mid, max = tf_verts.to_a.sort { |a, b| a.y <=> b.y }

      self.scan_triangle min, mid, max, texture
    end

    def scan_edges(a : Shale::Edge, b : Shale::Edge, swap : Bool, gradient : Gradient, texture : Shale::Surface)
      left = a
      right = b

      left, right = right, left if swap

      y_end = b.y_end
      y_start = b.y_start

      (y_start...y_end).each do |y|
        self.draw_scan_line left, right, y, gradient, texture
        left.step
        right.step
      end
    end

    def scan_triangle(min : Shale::Vertex, mid : Shale::Vertex, max : Shale::Vertex, texture : Shale::Surface)
      # For now, from the video series, using the calculation to just find the area for the given vertices to
      # decide what the handedness should be, eventhou the area value isn't correct here for a triangle (the actual
      # area would be half of the return amount)
      area = Shale::Maths.parallelogram_area min, max, mid

      gradient = Gradient.new min, mid, max

      top_to_bottom = Shale::Edge.new min, max, gradient, 0
      top_to_middle = Shale::Edge.new min, mid, gradient, 0
      mid_to_bottom = Shale::Edge.new mid, max, gradient, 1

      self.scan_edges top_to_bottom, top_to_middle, area >= 0, gradient, texture
      self.scan_edges top_to_bottom, mid_to_bottom, area >= 0, gradient, texture
    end
  end
end
