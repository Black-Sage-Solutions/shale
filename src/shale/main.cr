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

  def self.main
    puts "Starting..."

    d = Shale::Display.new(width: 800_u32, height: 600_u32, title: "Shale")
    pp d

    stars = Shale::Stars3D.new 4096, 60_f32, 5_f32

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
          if d.width != e.width.to_u32 || d.height != e.height.to_u32
            d.resize e.width.to_u32, e.height.to_u32
            break
          end
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
        d.draw do |frame|
          frame.clear 0x77_u8
          stars.render target: frame, delta: delta
        end
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
