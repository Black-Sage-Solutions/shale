require "math"

require "./surface"

module Shale
  class Stars3D
    @stars_x : Slice(Float32)
    @stars_y : Slice(Float32)
    @stars_z : Slice(Float32)

    def initialize(@num_of_stars : Int32, @spread : Float32, @speed : Float32)
      @stars_x = Slice(Float32).new @num_of_stars
      @stars_y = Slice(Float32).new @num_of_stars
      @stars_z = Slice(Float32).new @num_of_stars

      @stars_x.fill { |i| self.face_pos }
      @stars_y.fill { |i| self.face_pos }
      @stars_z.fill { |i| self.dist_pos }
    end

    def face_pos : Float32
      2 * (rand(1_f32) - 0.5_f32) * @spread
    end

    def dist_pos : Float32
      (rand(1_f32) + 0.00001_f32) * @spread
    end

    def reset_star(i : Int32)
      @stars_x[i] = self.face_pos
      @stars_y[i] = self.face_pos
      @stars_z[i] = self.dist_pos
    end

    def render(target : Shale::Surface, delta : Float64)
      half_width = target.width / 2
      half_height = target.height / 2

      rad = (90/2)*(Math::PI/180)
      half_fov = Math.tan rad

      (0...@num_of_stars).each do |i|
        @stars_z[i] -= delta * @speed

        if @stars_z[i] <= 0
          self.reset_star i
        end

        x = ((@stars_x[i] / (@stars_z[i] * half_fov)) * half_width + half_width)
        y = ((@stars_y[i] / (@stars_z[i] * half_fov)) * half_height + half_height)

        if x < 0 || x >= target.width || y < 0 || y >= target.height
          self.reset_star i
        else
          target.map_pixel x.to_u32, y.to_u32, 255_u8, 255_u8, 255_u8
        end
      end
    end
  end
end
