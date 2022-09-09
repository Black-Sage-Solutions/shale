module Shale
  struct Surface
    getter data : Bytes
    getter height
    getter width

    # Create a surface buffer.
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
      @data = Bytes.new @width * @height * @channels
      clear
    end

    def inspect(io : IO) : Nil
      io << {{@type.name.id.stringify}} << '('
      {% for ivar, i in @type.instance_vars %}
        {% if i > 0 %}
          io << ", "
        {% end %}
        {% if ivar.name == "data" %}
          io << "@{{ivar.id}}="
          io << typeof(@{{ivar.id}})
          io << "(size: "
          io << @{{ivar.id}}.size
          io << ')'
        {% else %}
          io << "@{{ivar.id}}="
          @{{ivar.id}}.inspect(io)
        {% end %}
      {% end %}
      io << ')'
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
      @data.fill shade
    end

    # Map pixel to the surface
    #
    # ### Arguments
    # - **x** Horizontal coordinate.
    # - **y** Vertial coordinate.
    # - **\*colours** Tuple of colour values, order currently is for BGRA.
    #
    # ### Description
    # Maps a pixel at the exact coordinate in the surface buffer with the
    # provided colour channels.
    #
    # There is bounds checking on the incoming parameters, and the mapping of
    # the colours are using `Slice#unsafe_put` method to skip its own bounds
    # checking. This is done for performance reasons, however (in limited test
    # time) the speed up is more significant when not building with the
    # `--release` flag.
    #
    # NOTE: Im not sure about a splat for the incoming colours, since I'm not
    # sure if or how to support other colour channel sequences, i.e. CMYK,
    # YCbCr, etc.
    #
    def map_pixel(x : UInt32, y : UInt32, *colours : UInt8)
      if 1 > x || x > @width || 1 > y || y > @height
        return
      end

      if colours.size > @channels
        raise "Incoming number of colour channels is too high"
      end

      # The (x - 1) is to fix a graphical error when the framebuffer is
      # larger than the display window, but not sure if this is the right fix
      start = ((y - 1) * @width + (x - 1)) * @channels
      colours.each_with_index { |e, i| @data.unsafe_put(start + i, e) }
    end

    def to_unsafe : Pointer(Bytes)
      pointerof(@data)
    end
  end
end
