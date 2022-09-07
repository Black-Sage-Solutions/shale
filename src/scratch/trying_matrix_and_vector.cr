require "../shale/matrix"
require "../shale/vector"

# struct Vector(T, N)
#   include Comparable(Vector)
#   include Indexable::Mutable(T)

#   @data : StaticArray(T, N)

#   @@axis_order = [:x, :y, :z, :w]

#   def initialize(value : T)
#     @data = StaticArray(T, N).new value
#   end

#   def initialize(*values : T)
#     # I tried to see if compiler compliation could check if the correct number
#     # of values are incoming, but doesn't seem like you can get the actual
#     # values from the function args
#     raise "Mismatch number of values: (#{values.size}), expecting: (#{N})" if values.size != N
#     @data = StaticArray(T, N).new { |i| values[i] }
#   end

#   macro [](*args)
#     Vector(typeof({{*args}}), {{args.size}}).new {{*args}}
#   end

#   def [](axis : Symbol) : T
#     p axis
#   end

#   def <=>(other : T)
#   end

#   def size
#     N
#   end

#   def to_unsafe : Pointer(T)
#     @data.to_unsafe
#   end

#   def unsafe_fetch(index : Int) : T
#     to_unsafe[index]
#   end

#   def unsafe_put(index : Int, value : T)
#     to_unsafe[index] = value
#   end
# end

# Is it better to have separate types for Vectors with specific axis or
# have a class/struct just take in a tuple of `n` amout of axes
{% begin %}
    {%
      axes = {
        2 => %w(x y),
        3 => %w(x y z),
        4 => %w(x y z w),
      }
    %}

    {% for num, vars in axes %}
      struct OldVector{{num}}(T)
        getter {{ *vars }}

        def initialize({{ *vars.map { |v| "@#{v.id} : T".id } }})
        end
      end
    {% end %}
  {% end %}

def main
  # test = Vector(Float32, 3).new 1_f32, 2_f32, 4_f32 # , 5_f32  # no warning is done when exceeding the allocated size, although it's not a problem logic-wise
  # pp test[2]
  # pp test[3]?

  # test2 = Vector[8_f32, 16_f32]
  # pp test2

  # test3 = Shale::Vector4[1_f32, 2_f32, 3_f32, 1_f32]
  # pp test3
  # pp test3 + Shale::Vector4[5_f32, 5_f32, 10_f32, 0_f32]
  # pp test3

  test4 = Shale::Matrix4(Float32).new.ss_transform 250.0, 225.0
  pp test4
end

main
