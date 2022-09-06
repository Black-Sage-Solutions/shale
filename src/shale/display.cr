require "x11"

require "./surface"

module Shale
  class Display
    @default_depth : Int32
    @default_gc : X11::C::X::GC
    @display : X11::Display
    @frame : X11::Image
    @frame_buffer : Shale::Surface
    @visual : X11::Visual
    @window : X11::C::Window

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
    #
    # FIXME: for the x11 pixmap, it seems to be a mismatch by 1 pixel when displaying in the window
    # example: if the window width (499) is less than the framebuffer width (500) (on the righthand side)
    # some reason, the last column of pixels in the framebuffer are show on the lefthand side by 1 pixel
    # UPDATE: temp fix added to the Surface.map_pixel function, but should investigate more if the right
    # fix is to offset the incoming coords before mapping to the framebuffer
    #
    def initialize(@width : UInt32, @height : UInt32, title : String)
      @display = X11::Display.new

      if @display.nil?
        raise Exception.new "Failed to connect to X display."
      end

      screen = @display.default_screen_number

      @visual = @display.default_visual screen
      @default_depth = @display.default_depth screen
      @default_gc = @display.default_gc screen

      window_attr = X11::SetWindowAttributes.new
      window_attr.event_mask = X11::ButtonMotionMask | X11::ButtonPressMask | X11::ButtonReleaseMask |
                               X11::ExposureMask | X11::KeyPressMask | X11::KeyReleaseMask |
                               X11::StructureNotifyMask
      @window = @display.create_window(
        parent: @display.root_window(screen),
        x: 0,
        y: 0,
        width: @width,
        height: @height,
        border_width: 1_u32,
        depth: X11::C::CopyFromParent.to_i32,
        c_class: X11::C::InputOutput.to_u32,
        visual: @visual,
        valuemask: (X11::C::CWBorderPixel | X11::C::CWEventMask).to_u64, # these mask bits are defined in x11-cr as i64
        attributes: window_attr
      )

      @display.store_name @window, title

      # Sets the window's close button to actually quit
      @wm_delete_window = @display.intern_atom "WM_DELETE_WINDOW", false
      @display.set_wm_protocols @window, [wm_delete_window]

      @display.map_raised @window

      @frame_buffer = Surface.new @width, @height

      # TODO look into using the MIT-SHM extension, could be a potential speed-up/reduce latency for drawing
      @frame = @display.create_image(
        visual: @visual,
        depth: @default_depth.to_u32,
        format: X11::C::ZPixmap,
        offset: 0,
        data: @frame_buffer.data,
        width: @width,
        height: @height,
        bitmap_pad: 32,
        bytes_per_line: (@width * sizeof(UInt32)).to_i32, # Consider creating a color type
      )
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
    def draw(&block : Shale::Surface -> Nil)
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
      return unless @width != width || @height != height

      @height = height
      @width = width

      @frame_buffer = Shale::Surface.new @width, @height

      @frame = @display.create_image(
        visual: @visual,
        depth: @default_depth.to_u32,
        format: X11::C::ZPixmap,
        offset: 0,
        data: @frame_buffer.data,
        width: @width,
        height: @height,
        bitmap_pad: 32,
        bytes_per_line: (@width * sizeof(UInt32)).to_i32,
      )

      @display.sync true
    end

    # Swap buffer
    #
    # ### Description
    # Writes the X11 image, mapped with the Surface data, to the window for
    # display.
    #
    #
    def swap_buffer
      @display.put_image(
        d: @window,
        gc: @default_gc,
        image: @frame,
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
