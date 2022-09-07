module Shale
  struct Vertex
    @pos : Vector4(Float32)

    def initialize(x : Float32, y : Float32, z : Float32)
      @pos = Vector4[x, y, z, 1_f32]
    end

    def initialize(value : Vector4(Float32))
      @pos = value
    end

    def perspec_divide : self
      Vertex.new Vector4[@pos.x / @pos.w, @pos.y / @pos.w, @pos.z / @pos.w, @pos.w]
    end

    def transform(m : Matrix4(Float32)) : self
      Vertex.new m.transform(@pos)
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
