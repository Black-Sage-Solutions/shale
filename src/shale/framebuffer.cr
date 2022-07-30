module Shale
  struct FrameBuffer
    @data : Bytes

    getter data
    getter height
    getter width

    # Create a framebuffer.
    #
    # ### Arguments
    # - **width**
    # - **height**
    # - **channels**
    #
    # ### Description
    #
    #
    def initialize(@width : UInt32, @height : UInt32, @channels = 4)
      @data = Bytes.new(@width * @height * @channels)
      self.clear
    end

    def inspect(io : IO) : Nil
      io << "#<FrameBuffer @data.size=\"{{@data.size}}\">"
    end

    # Clear the buffer.
    #
    # ### Arguments
    # - **shade** Provide an 8-bit colour to fill the buffer.
    #
    # ### Description
    # This will fill in the buffer's `@data` property to clear whatever has been set.
    #
    def clear(shade : UInt8 = 0)
      @data.fill(shade)
    end

    # Map pixel to the frame
    #
    # ### Arguments
    # - **x** Horizontal coordinate.
    # - **y** Vertial coordinate.
    # - **\*colours** Tuple of colour values, order currently is for BGRA.
    #
    # ### Description
    # Maps a pixel at the exact coordinate in the frame with the provided colour
    # channels.
    #
    # There is bounds checking on the incoming parameters, and the mapping of
    # the colours are using `Slice#unsafe_put` method to skip its own bounds
    # checking. This is done for performance reasons, however (in limited test
    # time) the speed up is more significant when not building with the
    # `--release` flag.
    #
    # TODO: consider writing the self bounds checks under a flag for debug
    #
    # NOTE: Im not sure about a splat for the incoming colours, since I'm not
    # sure if or how to support other colour channel sequences, i.e. CMYK,
    # YCbCr, etc.
    #
    def map_pixel(x : UInt32, y : UInt32, *colours : UInt8)
      if x > @width
        raise "Bounds check failed: x (#{x}) is too high (#{@width})."
      end

      if y > @height
        raise "Bounds check failed: y (#{y}) is too high (#{@height})."
      end

      if colours.size > @channels
        raise "Incoming number of colour channels is too high"
      end

      start = (y * @width + x) * @channels
      # colours.each_with_index { |e, i| @data[start + i] = e }
      colours.each_with_index { |e, i| @data.unsafe_put(start + i, e) }
    end

    def to_unsafe : Pointer(Bytes)
      pointerof(@data)
    end
  end
end
