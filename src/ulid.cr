require "base32"

module Ulid
  VERSION = "0.1.3"

  class ULID
    class Error < Exception; end

    include Comparable(ULID)

    BYTE_COUNT = 16

    def_hash @bytes

    getter bytes : Bytes
    getter time : Time do
      ms = 0u64
      6.times { |i| ms |= @bytes[5 - i].to_u64 << (i * 8) }
      Time.unix_ms(ms)
    end

    def initialize(bytes : Bytes)
      initialize(bytes, true)
    end

    private def initialize(bytes : Bytes, copy : Bool)
      raise Error.new "Not enough bytes, #{BYTE_COUNT} required" if bytes.size < BYTE_COUNT
      raise Error.new "Too many bytes, #{BYTE_COUNT} required" if bytes.size > BYTE_COUNT
      @bytes = copy ? Bytes.new(BYTE_COUNT, read_only: true) { |i| bytes[i] } : bytes
    end

    def initialize(time : Time, random : Bytes)
      ms = time.to_unix_ms
      bytes = Bytes.new(BYTE_COUNT, read_only: true) do |i|
        i < 6 ? (ms >> (8 * (5 - i)) & 0xFF).to_u8 : random[i - 6]
      end
      initialize(bytes, false)
    end

    def initialize(time : Time, *, generator : Random = Random::PCG32)
      random = generator.random_bytes(10)
      initialize(time, random)
    end

    def initialize(*, generator : Random = Random::PCG32.new)
      random = generator.random_bytes(10)
      initialize(Time.utc, random)
    end

    def initialize(str : String)
      initialize(Base32.decode(str, Base32::Crockford))
    end

    def to_s(io : IO) : Void
      io << Base32.encode(@bytes, Base32::Crockford)
    end

    def inspect(io : IO) : Void
      io << "#<" << self.class.name << " "
      to_s(io)
      io << ">"
    end

    def <=>(other : ULID)
      @bytes.<=>(other.@bytes)
    end
  end
end
