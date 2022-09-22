require "io"
require "file"

# https://www.w3.org/TR/2003/REC-PNG-20031110/
module PNG
  PNG_ENDIAN = IO::ByteFormat::NetworkEndian # BigEndian
  SIG        = 0x89_50_4e_47_0d_0a_1a_0a

  module Critical
    IDAT = Bytes[0x49, 0x44, 0x41, 0x54]
    IEND = Bytes[0x49, 0x45, 0x4e, 0x44]
    IHDR = Bytes[0x49, 0x48, 0x44, 0x52]
    PLTE = Bytes[0x80, 0x76, 0x84, 0x69]
  end

  module Ancillary
    PHYS = Bytes[0x70, 0x48, 0x59, 0x73]
    TEXT = Bytes[0x74, 0x45, 0x58, 0x74]
  end

  module Chunk
    struct Type
      @data : Bytes

      def initialize(@data : Bytes)
        raise "Chunk::Type#name must be 4 bytes long: #{data.size}" if @data.size != 4
      end

      def name : String
        String.new @data, encoding: "LATIN1"
      end

      def inspect(io : IO) : Nil
        io << {{@type.name.id.stringify}} << '(' << name << ')'
      end

      def critical? : Bool
        @data[0].chr.ascii_uppercase
      end

      def public? : Bool
        @data[1].chr.ascii_uppercase
      end

      def standard? : Bool
        @data[2].chr.ascii_uppercase
      end

      def copy_safe? : Bool
        @data[3].chr.ascii_lowercase
      end

      def to_unsafe : Pointer(Bytes)
        pointerof(@data)
      end
    end
  end

  # Read a chunk of bytes from the incoming file/IO.
  #
  # ### Description
  # Following the spec in the 5.3 Chunk layout section, reads for the
  # signifcant bits on each part of the chunk. The bit structure is in 4 parts
  # or 3 parts if there is no data.
  #
  # ### Raises
  # If the length value is greater than the max value of `Int32`.
  #
  private def self.read_chunk(img : IO, skip_data : Bool = false)
    pos = img.pos

    buf = Bytes.new 4
    img.read buf
    len = PNG_ENDIAN.decode UInt32, buf

    buf = Bytes.new 4
    img.read buf
    chunk_type = Chunk::Type.new buf

    # FIXME, will need to think about memory? thou Bytes.new (and bytes.dup)
    # i think are allocated in the heap?
    if len > Int32::MAX
      raise "Chunk length is too large: #{len}"
    elsif skip_data
      img.skip len
    elsif len > 0
      buf = Bytes.new len
      img.read buf
      chunk_data = buf.dup
    else
      chunk_data = nil
    end

    buf = Bytes.new 4
    img.read buf
    crc = buf.dup

    {pos, len, chunk_type, chunk_data, crc}
  end

  def self.decode(filename)
    img = File.open filename

    signature = Bytes.new 8
    img.read signature

    raise "Missing PNG Signature" if signature.nil?
    raise "Incorrect PNG Signature" if PNG_ENDIAN.decode(UInt64, signature) != SIG

    chunks = Array(Tuple(Int64, UInt32, Chunk::Type, Bytes?, Bytes)).new

    while img.peek.not_nil!.empty?.!
      chunks << read_chunk img, skip_data: true
    end

    pp! chunks

    # ihdr_chunk = read_chunk img
    # pp! ihdr_chunk

    # phys_chunk = read_chunk img
    # pp! phys_chunk

    # width = Bytes.new 4
    # height = Bytes.new 4
    # bit_depth = Bytes.new 1
    # colour_type = Bytes.new 1
    # compress_meth = Bytes.new 1
    # filter_meth = Bytes.new 1
    # inter_meth = Bytes.new 1
  end

  # class PNG
  #   @data : Bytes.new 0

  #   def raw
  #   end
  # end
end
