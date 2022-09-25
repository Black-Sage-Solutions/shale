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

  enum ColourDepth
    Greyscale           = 0
    Truecolour          = 2
    IndexedColour       = 3
    GreyscaleWithAlpha  = 4
    TruecolourWithAlpha = 6
  end

  module ChunkType
    # def initialize(@pos : Int64, @len : UInt32, @type : Bytes, @data : Bytes?, @crc : Bytes)
    #   raise "Chunk type bytes must be 4 bytes long: #{type.size}" if type.size != 4
    # end
    # def inspect(io : IO) : Nil
    #   io << {{@type.name.id.stringify}} << '(' << name << ')'
    # end

    abstract def type : Bytes

    def name : String
      String.new type, encoding: "LATIN1"
    end

    def critical? : Bool
      type[0].chr.ascii_uppercase?
    end

    def public? : Bool
      type[1].chr.ascii_uppercase?
    end

    def standard? : Bool
      type[2].chr.ascii_uppercase?
    end

    def copy_safe? : Bool
      type[3].chr.ascii_lowercase?
    end
  end

  class IHDR
    include ChunkType

    getter type : Bytes = Critical::IHDR

    def initialize(@pos : Int64, @len : UInt32, @data : Bytes?)
      raise "Chunk type bytes must be 4 bytes long: #{type.size}" if type.size != 4
    end

    def width : Int32
      PNG_ENDIAN.decode Int32, @data[0..3]
    end

    def height : Int32
      PNG_ENDIAN.decode Int32, @data[4..7]
    end

    def bit_depth : UInt8
      @data[8]
    end

    def colour_type : ColourDepth
      ColourDepth.new @data.not_nil!.[9]
    end

    def compress_meth : UInt8
      @data[10]
    end

    def filter_meth : UInt8
      @data[11]
    end

    def inter_meth : UInt8
      @data[12]
    end
  end

  class PNG
    @data : Bytes

    def initialize(@width : UInt32, @height : UInt32, @bit_depth : Int32)
      @data = Bytes.new @width * @height * @bit_depth
      @data.fill 0_u8
    end
  end

  private def self.check_crc(checksum : Bytes, data : Bytes)
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
  private def self.read_chunk(img : IO, skip_data : Bool = false) # : Chunk
    pos = img.pos

    buf = Bytes.new 4
    img.read buf
    len = PNG_ENDIAN.decode UInt32, buf

    buf = Bytes.new 4
    img.read buf
    chunk_type = buf.dup

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

    # chunks = [] of Chunk
    chunks = Array(Tuple(Int64, UInt32, Bytes, Bytes?, Bytes)).new

    while img.peek.not_nil!.empty?.!
      chunks << read_chunk img
    end

    ihdr = chunks.find! &.[2].== Critical::IHDR

    phys = chunks.find &.[2].== Ancillary::PHYS

    texts = chunks.select &.[2].== Ancillary::TEXT

    idats = chunks.select! &.[2].== Critical::IDAT

    header = IHDR.new ihdr[0], ihdr[1], ihdr[3]

    pp! header.colour_type, header.critical?

    img.close
  end
end
