module Shale::TestDrawing
  extend self

  # Test single colour changes.
  #
  # ### Description
  # **WARNING** Using this will flicker the screen very rapidly with different
  # colours.
  #
  def test_seizure(target : Shale::FrameBuffer)
    b, g, r = Random.rand(StaticArray(UInt8, 3))
    (0_u32...target.height).each do |y|
      (0_u32...target.width).each do |x|
        target.map_pixel x, y, b, g, r
      end
    end
  end

  # Test random static on colour channels.
  #
  # ### Description
  # Each colour channel is randomized and drawn to the frame. With the `--debug`
  # enabled, it will be rather slow, but building with `--release` tends to
  # show significant speedup.
  #
  def test_static_colour(target : Shale::FrameBuffer)
    (0_u32...target.height).each do |y|
      (0_u32...target.width).each do |x|
        b, g, r = Random.rand(StaticArray(UInt8, 3))

        target.map_pixel x, y, b, g, r
      end
    end
  end

  # Test mapping pixels to the frame.
  #
  # ### Description
  # 4 quadrants are created with different colour patterns. Top left will be
  # randomized colours for each pixel, and the other 3 areas will have
  # gradients based on the xy coordinates.
  #
  def test_true_colour(target : Shale::FrameBuffer)
    mid_v = target.height / 2
    mid_x = target.width / 2

    (0_u32...target.height).each do |y|
      (0_u32...target.width).each do |x|
        if y < mid_v && x < mid_x
          b, g, r = Random.rand(StaticArray(UInt8, 3))

          target.map_pixel x, y, b, g, r
        else
          b = (y % 256).to_u8
          g = (x % 256).to_u8
          if y < target.height / 2
            r = (y % 256).to_u8
          elsif x < target.width / 2
            r = (x % 256).to_u8
          else
            r = ((256 - x) % 256).to_u8
          end
          target.map_pixel x, y, b, g, r
        end
      end
    end
  end
end
