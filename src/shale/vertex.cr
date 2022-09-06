module Shale
  alias Vertex = {x: Float32, y: Float32}

  def self.parallelogram_area(*vertices : Vector4) : Float32
    # condition was for when it was thought to be for a triangle when the
    # following logic is the area for a parallelogram
    #
    # case vertices.size
    # when .> 3
    #   raise "Too many vertices: (#{vertices.size})"
    # when .< 3
    #   raise "Too few vertices: (#{vertices.size})"
    # end

    a, b, c = vertices

    x1, y1 = b.x - a.x, b.y - a.y
    x2, y2 = c.x - a.x, c.y - a.y

    x1 * y2 - x2 * y1
  end
end
