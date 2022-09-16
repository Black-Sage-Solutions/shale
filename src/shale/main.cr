require "benchmark"
require "time"

require "x11"

module Shale
  struct Stats
    property cycles : UInt64 = 0_u64
    property last_draw_time_ms : Float64 = 0_f64
    property last_time_left_s : Float64 = 0_f64
    property total_draw_time_s : Float64 = 0_f64

    def average_draw_time : Float64
      total_draw_time_s / cycles
    end
  end

  WIDTH  = 800_u32
  HEIGHT = 600_u32
  FOV    =  70_f32

  def self.main
    puts "Starting..."

    d = Shale::Display.new(width: WIDTH, height: HEIGHT, title: "Shale")
    pp d

    stars = Shale::Stars3D.new 4096, 60_f32, 5_f32

    ctx = Shale::RenderCtx.new WIDTH.to_i, HEIGHT.to_i, d.frame_buffer

    a = Shale::Vertex.new Vector4[-1_f32, -1_f32, 0_f32, 1_f32], colour: Vector4[1_f32, 0_f32, 0_f32, 0_f32], tex_coords: Vector4[0_f32, 0_f32, 0_f32, 0_f32]
    b = Shale::Vertex.new Vector4[0_f32, 1_f32, 0_f32, 1_f32], colour: Vector4[0_f32, 1_f32, 0_f32, 0_f32], tex_coords: Vector4[0.5_f32, 1_f32, 0_f32, 0_f32]
    c = Shale::Vertex.new Vector4[1_f32, -1_f32, 0_f32, 1_f32], colour: Vector4[0_f32, 0_f32, 1_f32, 0_f32], tex_coords: Vector4[1_f32, 0_f32, 0_f32, 0_f32]

    texture = Shale::Surface.new 32, 32

    texture.height.times do |y|
      texture.width.times do |x|
        bl, gr, re, al = Random.rand(StaticArray(UInt8, 4))
        texture.map_pixel x, y, bl, gr, re, al
      end
    end

    projection = Shale::Matrix4(Float32).new.perspective FOV, (WIDTH / HEIGHT).to_f32, 0.1, 1000_f32
    rotation_count = 0_f32

    prev_time = Time.monotonic
    stats = Stats.new
    quit = false

    loop do
      current_time = Time.monotonic
      delta = (current_time - prev_time).total_seconds
      prev_time = current_time

      while d.pending > 0
        e = d.next_event
        case e
        when X11::ClientMessageEvent
          if e.long_data[0] == d.wm_delete_window
            quit = true
            break
          end
        when X11::ConfigureEvent
          d.resize e.width.to_u32, e.height.to_u32
          ctx = Shale::RenderCtx.new e.width, e.height, d.frame_buffer
          projection = Shale::Matrix4(Float32).new.perspective FOV, (e.width / e.height).to_f32, 0.1, 1000_f32
          break
        when X11::KeyEvent
          pp e.lookup_string
          if e.keycode == 24
            quit = true
            break
          end
        end

        p e
      end

      break if quit

      results = Benchmark.measure "Draw Time" do
        rotation_count += delta * 75
        translation = Shale::Matrix4(Float32).new.identity.translation 0_f32, 0_f32, 3_f32
        rotation = Shale::Matrix4(Float32).new.rotation 0_f32, rotation_count, 0_f32
        transform = projection * (translation * rotation)

        d.clear

        # stars.render target: d.frame_buffer, delta: delta
        # ctx.scan_to_triangle a, b, c, 0
        # ctx.draw frame, 100_u32, 300_u32
        #
        ctx.draw_triangle c.transform(transform), b.transform(transform), a.transform(transform), texture: texture

        d.swap_buffer
      end

      stats.cycles += 1
      stats.last_draw_time_ms = results.total * 1_000
      stats.last_time_left_s = ((1 / 60) - delta)
      stats.total_draw_time_s += results.total

      p stats

      sleep stats.last_time_left_s if stats.last_time_left_s > 0
    end

    p "Avg Draw Time: #{stats.average_draw_time * 1_000}ms"

    d.close
    0
  end
end
