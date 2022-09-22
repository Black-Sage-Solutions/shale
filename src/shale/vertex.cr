module Shale
  struct Vertex
    @pos : Vector4(Float32)

    getter colour : Vector4(Float32)
    getter tex_coords : Vector4(Float32)

    def initialize(@pos : Vector4(Float32), @colour : Vector4(Float32), @tex_coords : Vector4(Float32))
    end

    def perspec_divide : self
      Vertex.new Vector4[@pos.x / @pos.w, @pos.y / @pos.w, @pos.z / @pos.w, @pos.w], @colour, @tex_coords
    end

    def transform(m : Matrix4(Float32)) : self
      Vertex.new m.transform(@pos), @colour, @tex_coords
    end

    def w : Float32
      @pos.w
    end

    def x : Float32
      @pos.x
    end

    def y : Float32
      @pos.y
    end

    def z : Float32
      @pos.z
    end
  end
end
