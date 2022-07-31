require "x11"

require "./framebuffer"

module Shale
  class Display
    @display : X11::Display
    @frame_buffer : Shale::FrameBuffer
    @gc : X11::C::X::GC
    @img : X11::Image
    @window : X11::C::Window
    @window_attr : X11::SetWindowAttributes

    getter height
    getter width
    getter wm_delete_window : X11::C::Atom

    # Create a display
    #
    # ### Arguments
    # - **@width** Width of the X11 window
    # - **@height** Height of the X11 window
    # - **title** The title added to the X11 window
    #
    # ### Description
    #
    def initialize(@width : UInt32, @height : UInt32, title : String)
      @display = X11::Display.new

      if @display.nil?
        raise Exception.new "Failed to connect to X display."
      end

      screen = @display.default_screen_number
      visual = @display.default_visual screen # maybe need a copy visual, 1 step part of avoiding flickering on resizing the window
      root_win = @display.root_window screen
      default_depth = @display.default_depth screen
      default_gc = @display.default_gc screen
      black_pix = @display.black_pixel screen

      @window_attr = X11::SetWindowAttributes.new
      @window_attr.event_mask = X11::ButtonMotionMask | X11::ButtonPressMask | X11::ButtonReleaseMask |
                                X11::ExposureMask | X11::KeyPressMask | X11::KeyReleaseMask |
                                X11::StructureNotifyMask
      @window = @display.create_window(
        parent: root_win,
        x: 0,
        y: 0,
        width: @width,
        height: @height,
        border_width: 1_u32,
        depth: X11::C::CopyFromParent.to_i32,
        c_class: X11::C::CopyFromParent.to_u32,
        visual: visual,
        valuemask: X11::C::CWBackPixel | X11::C::CWBorderPixel | X11::C::CWEventMask,
        attributes: @window_attr
      )

      @display.set_foreground default_gc, black_pix

      @display.store_name @window, title

      # Sets the window's close button to actually quit
      @wm_delete_window = @display.intern_atom "WM_DELETE_WINDOW", false
      @display.set_wm_protocols @window, [wm_delete_window]

      @display.map_raised @window

      @frame_buffer = FrameBuffer.new @width, @height

      @img = @display.create_image(
        visual: visual,
        depth: default_depth.to_u32,
        format: X11::C::ZPixmap,
        offset: 0,
        data: @frame_buffer.data,
        width: @width,
        height: @height,
        bitmap_pad: 32,
        bytes_per_line: (@width * sizeof(UInt32)).to_i32, # Consider creating a color type
      )

      gc_values_struct = uninitialized X11::C::X::GCValues
      gc_values = X11::GCValues.new pointerof(gc_values_struct)

      # @gc = @display.create_gc d: @pixmap, valuemask: 0_u64, values: gc_values
      @gc = @display.create_gc d: @window, valuemask: 0_u64, values: gc_values

      @display.set_graphics_exposures @gc, true
    end

    # Close and clean up the X11 display
    #
    # ### Description
    # From the X11 documentation, this will also include other resources that
    # have been linked to the display (window, gfx context, pixmaps, etc).
    #
    def close : Int32
      @display.close
    end

    # Draw to the Display's buffer
    #
    # ### Description
    #
    def draw(&block : Shale::FrameBuffer -> Nil)
      @frame_buffer.clear

      yield @frame_buffer

      self.swap_buffer
    end

    # Cleanup garbage collection method
    #
    # ### Description
    # When garbage collection (GC) is initiated, it will call the Display's
    # `close` method and cleanup X11 resources
    #
    def finalize : Int32
      close
    end

    def flush
      @display.flush
    end

    def inspect(io : IO) : Nil
      io << "#<Display @frame_buffer=#{@frame_buffer} >"
    end

    def next_event
      @display.next_event
    end

    def pending
      @display.pending
    end

    # Resize the drawing area
    #
    # ### Description
    #
    #
    # TODO: move into a new method, and also refactor init method to
    # `uninitialize` the necessary properties.
    #
    def resize(width : UInt32, height : UInt32)
      @height = height
      @width = width

      screen = @display.default_screen_number
      default_depth = @display.default_depth screen
      visual = @display.default_visual screen

      @img.finalize

      @frame_buffer = Shale::FrameBuffer.new width, height

      @img = @display.create_image(
        visual: visual,
        depth: default_depth.to_u32,
        format: X11::C::ZPixmap,
        offset: 0,
        data: @frame_buffer.data,
        width: @width,
        height: @height,
        bitmap_pad: 32,
        bytes_per_line: (@width * sizeof(UInt32)).to_i32,
      )

      self.swap_buffer

      @display.sync true
    end

    # Swap buffer
    #
    # ### Description
    # Writes the X11 image, mapped with the framebuffer data, to the window for
    # display.
    #
    def swap_buffer
      @display.put_image(
        d: @window,
        gc: @gc,
        image: @img,
        src_x: 0,
        src_y: 0,
        dest_x: 0,
        dest_y: 0,
        width: @width,
        height: @height,
      )
    end

    def sync(discard : Bool)
      @display.sync discard
    end
  end
end
