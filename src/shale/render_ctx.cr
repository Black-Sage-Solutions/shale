module Shale
  class RenderCtx
    @data : Array(UInt32)

    # Render Context
    #
    # ### Description
    #
    # For now to save time and getting things working, just following the implementation
    # from the video series, in the future (depending on where this class' goes), would be good to change:
    #
    # * Not relying on the 'window' dimensions for the size of @data
    # * Conform on which type of Int?
    def initialize(@width : Int32, @height : Int32)
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

    def draw_triangle(*vertices : Shale::Vertex, target : Shale::Surface)
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
      handedness = area >= 0 ? 1 : 0

      self.scan_to_triangle min, mid, max, handedness
      self.draw target, min.y.ceil.to_u32, max.y.ceil.to_u32
    end

    def scan_to_triangle(min : Shale::Vertex, mid : Shale::Vertex, max : Shale::Vertex, which_hand : Int)
      self.scan_to_line min, max, 0 + which_hand
      self.scan_to_line min, mid, 1 - which_hand
      self.scan_to_line mid, max, 1 - which_hand
    end

    def scan_to_line(min : Shale::Vertex, max : Shale::Vertex, which_hand : Int)
      x_dist = max.x - min.x
      y_dist = max.y - min.y

      return if y_dist <= 0

      x_step = x_dist / y_dist
      current_x = min.x + (min.y.ceil.to_i - min.y) * x_step

      (min.y.ceil.to_u32...max.y.ceil.to_u32).each do |y|
        @data[y * 2 + which_hand] = current_x.ceil.to_u32
        current_x += x_step
      end
    end

    def set(y : UInt32, x_begin : UInt32, x_end : UInt32)
      @data[y * 2] = x_begin
      @data[y * 2 + 1] = x_end
    end
  end
end
