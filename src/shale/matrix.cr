module Shale
  struct Matrix4(T)
    include Indexable::Mutable(T)

    POINTS = 16

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

    @data = StaticArray(T, POINTS).new T.zero

    def [](x : Int8, y : Int8) : T
    end

    def []=(x : Int8, y : Int8) : T
    end

    def col(index : Int) : Slice(T)
    end

    def identity
      # Not sure when this state is used
      # would set 1 like such:
      #
      # 1_f32 0_f32 0_f32 0_f32
      # 0_f32 1_f32 0_f32 0_f32
      # 0_f32 0_f32 1_f32 0_f32
      # 0_f32 0_f32 0_f32 1_f32
    end

    def inspect(io : IO) : Nil
      io << {{@type}}
      io << "([#{@data.join(", ")}])"
    end

    def mult(other : Matrix4(T)) : self
    end

    def perspective(fov : Float32, aspect_ratio : Float32, z_near : Float32, z_far : Float32) : self
    end

    def pretty_print(pp : PrettyPrint) : Nil
      # TODO get largest number, and check
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
    def rotation(x, y, z, w) : self
    end

    # Consider just taking in a Shale::Vector4?
    def scale(x, y, z, w) : self
    end

    def size
      POINTS
    end

    # Consider just taking in a Shale::Vector4?
    def translation(x, y, z, w) : self
    end

    def unsafe_fetch(index : Int)
      @data.unsafe_fetch index
    end

    def unsafe_put(index : Int, value : T)
      @data.unsafe_put index, value
    end
  end
end
