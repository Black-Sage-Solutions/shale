module Shale
  alias Vertex = {x: Float32, y: Float32}

  # TODO move somewhere more appropriate
  def self.triangle_area(*vertices : Vertex) : Float32
    case vertices.size
    when .> 3
      raise "Too many vertices: (#{vertices.size})"
    when .< 3
      raise "Too few vertices: (#{vertices.size})"
    end

    a, b, c = vertices

    x1, y1 = b[:x] - a[:x], b[:y] - a[:y]
    x2, y2 = c[:x] - a[:x], c[:y] - a[:y]

    x1 * y2 - x2 * y1
  end
end
