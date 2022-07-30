require "benchmark"
require "time"

require "x11"

module Shale
  def self.main
    puts "Starting..."

    d = Shale::Display.new(width: 800_u32, height: 600_u32, title: "Shale")
    pp d

    stars = Shale::Stars3D.new 4096, 60_f32, 5_f32

    cycles = 0_u64
    prev_time = Time.monotonic
    quit = false

    loop do
      current_time = Time.monotonic
      delta = (current_time - prev_time).total_seconds
      prev_time = current_time

      while d.pending > 0
        e = d.next_event
        # pp e
        case e
        when X11::NoExposeEvent
          break
        when X11::ExposeEvent
          break
        when X11::ClientMessageEvent
          if e.long_data[0] == d.wm_delete_window
            quit = true
            break
          end
        when X11::ConfigureEvent
          if d.width != e.width.to_u32 || d.height != e.height.to_u32
            d.resize e.width.to_u32, e.height.to_u32
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
          stars.render target: frame, delta: delta
        end
      end

      d.swap_buffer

      p "#{results.label}: #{results.total * 1000}ms"

      cycles += 1

      sleep 1 / 60
    end

    p "cycles: #{cycles}"

    d.close
    0
  end
end
