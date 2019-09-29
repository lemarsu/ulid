require "spec"
require "timecop"
require "../src/ulid"

def array_slice(array : Array(UInt8)) : Bytes
  Bytes.new 16 { |i| array[i] }
end

class NotRandom
  include Random

  def initialize(@seed : UInt8)
  end

  def next_u
    @seed += 1
  end
end
