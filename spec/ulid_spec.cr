require "./spec_helper"

describe Ulid::ULID do
  # TODO: Write tests

  it "should initialize" do
    bytes = Bytes.new(16, 0u8)
    ulid = Ulid::ULID.new(bytes)
    ulid.bytes.should eq bytes
  end

  it "should refuse slice of wrong size" do
    not_enough_bytes = Bytes.new(10, 0u8)
    too_many_bytes = Bytes.new(20, 0u8)
    expect_raises Ulid::ULID::Error, "Not enough bytes" do
      Ulid::ULID.new not_enough_bytes
    end
    expect_raises Ulid::ULID::Error, "Too many bytes" do
      Ulid::ULID.new too_many_bytes
    end
  end

  it "should serialize a date" do
    time = Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_456_789)
    random = Bytes.new(10) { |i| (201 + i).to_u8 }
    ulid = Ulid::ULID.new(time, random)
    ulid.bytes.to_a.should eq [
      1, 109, 124, 169, 34, 11,
      201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
    ] of UInt8
  end

  it "should generate random" do
    time = Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_456_789)
    generator = NotRandom.new(200)
    ulid = Ulid::ULID.new(time, generator: generator)
    ulid.bytes.to_a.should eq [
      1, 109, 124, 169, 34, 11,
      201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
    ]
  end

  it "should generate random and use current date" do
    time = Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_456_789)
    generator = NotRandom.new(200)
    ulid = nil
    Timecop.freeze(time) do
      ulid = Ulid::ULID.new(generator: generator)
    end
    ulid.not_nil!.bytes.to_a.should eq [
      1, 109, 124, 169, 34, 11,
      201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
    ]
  end

  it "#to_s should return Crockford's Base32 of bytes" do
    bytes = array_slice [
      101, 102, 103, 104, 105, 106,
      107, 108, 109, 110, 111, 112, 113, 114, 115, 116,
    ] of UInt8
    ulid = Ulid::ULID.new(bytes)
    ulid.to_s.should eq "CNK6ET39D9NPRVBEDXR72WKKEG"
  end

  it "should return a custom inspect value" do
    bytes = array_slice [
      101, 102, 103, 104, 105, 106,
      107, 108, 109, 110, 111, 112, 113, 114, 115, 116,
    ] of UInt8
    ulid = Ulid::ULID.new(bytes)
    ulid.inspect.should eq "#<Ulid::ULID CNK6ET39D9NPRVBEDXR72WKKEG>"
  end

  it "should instantiate from a string" do
    ulid = Ulid::ULID.new "CNK6ET39D9NPRVBEDXR72WKKEG"
    ulid.to_s.should eq "CNK6ET39D9NPRVBEDXR72WKKEG"
  end

  it "should return back time" do
    time = Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_456_789)
    random = Bytes.new(10) { |i| (201 + i).to_u8 }
    ulid = Ulid::ULID.new(time, random)
    ulid.time.should eq Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_000_000)
  end

  it "should be comparable" do
    ulid1 = Ulid::ULID.new(array_slice [
      1, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 16,
    ] of UInt8)
    ulid2 = Ulid::ULID.new(array_slice [
      2, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 16,
    ] of UInt8)
    ulid3 = Ulid::ULID.new(array_slice [
      1, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 17,
    ] of UInt8)
    ulid4 = Ulid::ULID.new(array_slice [
      1, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 16,
    ] of UInt8)

    (ulid2 > ulid1).should be_true
    (ulid3 > ulid1).should be_true
    (ulid2 > ulid3).should be_true
  end

  it "should only compare bytes" do
    bytes = array_slice [
      1, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 16,
    ] of UInt8
    ulid1 = Ulid::ULID.new(bytes)
    ulid2 = Ulid::ULID.new(bytes)

    # Generate time instance cache
    ulid2.time

    (ulid1 == ulid2).should be_true
  end

  it "should return a readonly slice" do
    ulid = Ulid::ULID.new
    ulid.bytes.read_only?.should be_true

    ulid = Ulid::ULID.new(array_slice [
      1, 2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15, 16,
    ] of UInt8)
    ulid.bytes.read_only?.should be_true

    time = Time.utc(2019, 9, 29, 10, 55, 22, nanosecond: 123_456_789)
    random = Bytes.new(10) { |i| (201 + i).to_u8 }
    ulid = Ulid::ULID.new(time, random)
    ulid.bytes.read_only?.should be_true
  end
end
