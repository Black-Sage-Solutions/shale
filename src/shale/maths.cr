require "math"

module Shale::Maths
  def self.parallelogram_area(*vertices : Vertex) : Float32
    # condition was for when it was thought to be for a triangle when the
    # following logic is the area for a parallelogram
    #
    # case vertices.size
    # when .> 3
    #   raise "Too many vertices: (#{vertices.size})"
    # when .< 3
    #   raise "Too few vertices: (#{vertices.size})"
    # end

    # FIXME incase this function is actually used for a 4 point shape and is
    # included in the args
    a, b, c = vertices

    x1, y1 = b.x - a.x, b.y - a.y
    x2, y2 = c.x - a.x, c.y - a.y

    x1 * y2 - x2 * y1
  end

  def self.tirangle_area(*vertices : Vertex) : Float32
    0.5 * parallelogram_area(*vertices)
  end

  def self.to_rad(deg : Number) : Float
    deg * (Math::PI / 180)
  end
end
