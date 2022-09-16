module Shale
  struct Surface
    getter channels
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

    # quick and dirty way to copy value from slice to slice, trying to get it
    # working first from what's coded in the video, then i will look up another way that maybe better from the crystal docs
    def copy_pixel(dest_x, dest_y, src_x, src_y, src : Surface)
      dest_i = (dest_x + dest_y * @width) * @channels
      src_i = (src_x + src_y * src.width) * src.channels

      @data.unsafe_put(dest_i, src.data.unsafe_fetch(src_i))         # b
      @data.unsafe_put(dest_i + 1, src.data.unsafe_fetch(src_i + 1)) # g
      @data.unsafe_put(dest_i + 2, src.data.unsafe_fetch(src_i + 2)) # r
      @data.unsafe_put(dest_i + 3, src.data.unsafe_fetch(src_i + 3)) # a
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
