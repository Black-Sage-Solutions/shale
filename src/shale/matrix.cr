require "math"

module Shale
  # Matrix4
  #
  # ### Description
  #
  # FIXES:
  #
  # * Figure out the best flow for the data setting and method operations
  # * Not sure about the efficency of the value setting, like with #identity,
  #   then doing out of order changes to other indices, what if, at all,
  #   performance loss is there
  struct Matrix4(T)
    include Indexable::Mutable(T)

    POINTS = 16
    SIDE   = Math.isqrt POINTS

    # Hmmm, what would be easier here? flat array or actual multidimensional
    #
    # @data[1, 1] <- for flat?
    # @data[1][1] <- multi, more conventional
    #
    # Also, this buffer is being allocated on the stack rather than the heap,
    # is this a good idea? is there a performance benefit? not sure what
    # problems could arise doing it this way, most implementations i've searched
    # seem to allocate on the heap
    #
    # So, using the multidimensional static array is not really working when
    # it comes to doing mutability with the data.
    # @data = StaticArray(StaticArray(T, 4), 4).new StaticArray(T, 4).new T.zero

    protected property data
    @data = StaticArray(T, POINTS).new T.zero

    def *(other : Matrix4(T)) : self
      mat = Matrix4(T).new

      SIDE.times do |y|
        SIDE.times do |x|
          mat[y, x] = (
            self[y, 0] * other[0, x] +
            self[y, 1] * other[1, x] +
            self[y, 2] * other[2, x] +
            self[y, 3] * other[3, x]
          )
        end
      end

      mat
    end

    # Reason for flipping [x, y] is to match what is conventionally written in something like C
    # where a multidim array would be equalivant matrix[y][x]
    #
    # Not sure to have it like you would if writting on paper (x, y), maybe with symbols [x: 0, y: 0]?
    def [](y : Int, x : Int) : T
      @data[SIDE * y + x]
    end

    def []=(y : Int, x : Int, value : T) : T
      @data[SIDE * y + x] = value
      value
    end

    # Setting @data points (not sure of the significance thou)
    #
    # ### Description
    #
    # The matrix is setup as such:
    #   1 0 0 0
    #   0 1 0 0
    #   0 0 1 0
    #   0 0 0 1
    #
    def identity : self
      @data[0] = @data[5] = @data[10] = @data[15] = T.new 1
      self
    end

    def inspect(io : IO) : Nil
      io << {{@type}}
      io << "([#{@data.join(", ")}])"
    end

    def perspective(fov : Float32, aspect_ratio : Float32, z_near : Float32, z_far : Float32) : self
      tan_half_fov = Math.tan(Shale::Maths.to_rad(fov) / 2)

      z_range = z_near - z_far

      @data[0] = (1_f32 / (tan_half_fov * aspect_ratio)).to_f32
      @data[5] = (1_f32 / tan_half_fov).to_f32
      @data[10] = (-z_near - z_far) / z_range
      @data[11] = 2 * z_far * z_near / z_range # not sure if order of ops is a problem here? (with z_near / z_range probably being first, not sure if intensional)
      @data[14] = 1_f32
      self
    end

    def pretty_print(pp : PrettyPrint) : Nil
      # TODO get largest number, and check size for padding what will be printed
      col_pad = nil
      pp.text {{@type}}
      # Bit crude, but will improve later
      pp.text "([\n"
      @data.each_slice(4) do |s|
        pp.text "  #{s.join(", ")}\n"
      end
      pp.text "])"
    end

    # Consider just taking in a Shale::Vector4?
    def rotation(x : Number, y : Number, z : Number) : self
      # since there's only a few spots, maybe to save a few ops, to just identity
      # here manually
      rx = Matrix4(Float32).new.identity
      ry = Matrix4(Float32).new.identity
      rz = Matrix4(Float32).new.identity

      x_rad = Shale::Maths.to_rad(x)
      y_rad = Shale::Maths.to_rad(y)
      z_rad = Shale::Maths.to_rad(z)

      x_cos = Math.cos x_rad
      y_cos = Math.cos y_rad
      z_cos = Math.cos z_rad

      x_sin = Math.sin x_rad
      y_sin = Math.sin y_rad
      z_sin = Math.sin z_rad

      rx[5] = x_cos
      rx[6] = -x_sin
      rx[9] = x_sin
      rx[10] = x_cos

      ry[0] = y_cos
      ry[2] = -y_sin
      ry[8] = y_sin
      ry[10] = y_cos

      rz[0] = z_cos
      rz[1] = -z_sin
      rz[4] = z_sin
      rz[5] = z_cos

      @data = (rz * ry * rx).data
      self
    end

    # Consider just taking in a Shale::Vector4?
    def scale(x : T, y : T, z : T) : self
      @data[0] = x
      @data[5] = y
      @data[10] = z
      self
    end

    def size
      POINTS
    end

    # Screen Space Transform
    #
    # ### Description
    #
    def ss_transform(half_width : T, half_height : T) : self
      @data[0] = half_width
      @data[3] = half_width
      @data[5] = -half_height
      @data[7] = half_height
      self
    end

    def transform(other : Vector4) : Vector4
      Vector4[
        @data[0] * other.x + @data[1] * other.y + @data[2] * other.z + @data[3] * other.w,
        @data[4] * other.x + @data[5] * other.y + @data[6] * other.z + @data[7] * other.w,
        @data[8] * other.x + @data[9] * other.y + @data[10] * other.z + @data[11] * other.w,
        @data[12] * other.x + @data[13] * other.y + @data[14] * other.z + @data[15] * other.w,
      ]
    end

    # Consider just taking in a Shale::Vector4?
    def translation(x : T, y : T, z : T) : self
      @data[3] = x
      @data[7] = y
      @data[11] = z
      self
    end

    def unsafe_fetch(index : Int)
      @data.unsafe_fetch index
    end

    def unsafe_put(index : Int, value : T)
      @data.unsafe_put index, value
    end
  end
end
