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
      Vector4(typeof({{*args}})).new {{*args}}
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

    def abs : self
      Vector4[@x.abs, @y.abs, @z.abs, @w.abs]
    end

    def cross(other : self) : self
      _x = @y * other.z - z * other.y
      _y = @z * other.x - x * other.z
      _z = @x * other.y - y * other.x

      # At this point not sure when these values would overflow
      Vector4[_x.to_f32, _y.to_f32, _z.to_f32, 0_f32]
    end

    def dot(other : self) : Float
      (@x * other.x) + (@y * other.y) + (@z * other.z)
    end

    def len : Float
      Math.sqrt @x.abs2 + @y.abs2 + @z.abs2
    end

    def lerp(other : self, factor : Float32) : self
      self * factor + self - other
    end

    def max : Float
      Math.max(Math.max(@x, y), Math.max(@z, @w))
    end

    def normalized : self
      self / self.len
    end
  end
end
