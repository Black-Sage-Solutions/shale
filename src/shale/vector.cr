require "math"

module Shale
  struct Vector4(T)
    getter x : T, y : T, z : T, w : T

    def initialize(@x : T, @y : T, @z : T, @w : T)
    end

    macro [](*args)
      # some reason without the namespace, crystal fails to find Vector4 here,
      # not sure if this is a problem only with trying to require this file 
      # in $project_root/test.cr or if it will be a problem in the project
      Shale::Vector4(typeof({{*args}})).new {{*args}}
    end

    def abs : self
      Vector4[@x.abs, @y.abs, @z.abs, @w.abs]
    end

    # Would and when this overflow?
    def cross(other : self) : self
      _x = @y * other.z - z * other.y
      _y = @z * other.x - x * other.z
      _z = @x * other.y - y * other.x

      Vector4[_x, _y, _z, 0_f32]
    end

    # When would this overflow?
    def dot(other : self) : Float32
      @x * other.x + @y * other.y + @z * other.z
    end

    # When would this overflow?
    def len : Float32
      Math.sqrt @x.abs2 + @y.abs2 + @z.abs2
    end

    # wtf is this for?
    def lerp(other : self, factor : Float32) : self
      other - self * factor + self
    end

    def max : Float32
      Math.max(Math.max(@x, y), Math.max(@z, @w))
    end

    def normalized : self
      self / self.len
    end

    def +(other : self) : self
      Vector4[@x + other.x, @y + other.y, @z + other.z, @w + other.w]
    end

    def +(value : Number) : self
      Vector4[@x + value, @y + value, @z + value, @w + value]
    end

    def -(other : self) : self
      Vector4[@x - other.x, @y - other.y, @z - other.z, @w - other.w]
    end

    def -(value : Number) : self
      Vector4[@x - value, @y - value, @z - value, @w - value]
    end

    def *(other : self) : self
      Vector4[@x * other.x, @y * other.y, @z * other.z, @w * other.w]
    end

    def *(value : Number) : self
      Vector4[@x * value, @y * value, @z * value, @w * value]
    end

    def /(other : self) : self
      Vector4[@x / other.x, @y / other.y, @z / other.z, @w / other.w]
    end

    def /(value : Number) : self
      Vector4[@x / value, @y / value, @z / value, @w / value]
    end

    def ==(other : self) : Bool
      @x == other.x && @y == other.y && @z == other.z && @w == other.w
    end
  end
end
