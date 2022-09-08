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
    def initialize(@width : Int32, @height : Int32, @target : Shale::Surface)
    end

    def draw_scan_line(left : Shale::Edge, right : Shale::Edge, y : UInt32)
      x_min = left.x.ceil.to_u32
      x_max = right.x.ceil.to_u32

      (x_min...x_max).each do |x|
        @target.map_pixel x, y, 0xff, 0xff, 0xff, 0xff
      end
    end

    def draw_triangle(*vertices : Shale::Vertex)
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

      # For now, from the video series, using the calculation to just find the area for the given vertices to
      # decide what the handedness should be, eventhou the area value isn't correct here for a triangle (the actual
      # area would be half of the return amount)
      area = Shale::Maths.parallelogram_area min, max, mid

      self.scan_triangle min, mid, max, (area >= 0)
    end

    def scan_edges(a : Shale::Edge, b : Shale::Edge, swap : Bool)
      left = a
      right = b

      left, right = right, left if swap

      y_end = b.y_end
      y_start = b.y_start

      (y_start...y_end).each do |y|
        self.draw_scan_line left, right, y
        left.step
        right.step
      end
    end

    def scan_triangle(min : Shale::Vertex, mid : Shale::Vertex, max : Shale::Vertex, swap : Bool)
      top_to_bottom = Shale::Edge.new min, max
      top_to_middle = Shale::Edge.new min, mid
      mid_to_bottom = Shale::Edge.new mid, max

      self.scan_edges top_to_bottom, top_to_middle, swap
      self.scan_edges top_to_bottom, mid_to_bottom, swap
    end
  end
end
