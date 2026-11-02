module Encryption
  ENCRYPTION_KEY = [0x4A, 0x8F, 0x2C, 0xE1, 0x73, 0xB5, 0x96, 0x0D,
                    0x5E, 0xA2, 0x3F, 0xC7, 0x81, 0x14, 0x6B, 0xD9]

  CHUNK_SIZE = 1 << 20

  def self.xor(data)
    key = ENCRYPTION_KEY.pack("C*")
    @full_chunk_key ||= (key * (CHUNK_SIZE / key.length)).unpack1("H*").to_i(16)
    full_chunk_key = @full_chunk_key
    result = String.new(capacity: data.bytesize, encoding: Encoding::BINARY)
    offset = 0
    while offset < data.bytesize
      chunk = data.byteslice(offset, CHUNK_SIZE)
      size = chunk.bytesize
      chunk_key = size == CHUNK_SIZE ? full_chunk_key : (key * (size / key.length + 1)).byteslice(0, size).unpack1("H*").to_i(16)
      xored = chunk.unpack1("H*").to_i(16) ^ chunk_key
      result << [xored.to_s(16).rjust(size * 2, "0")].pack("H*")
      offset += CHUNK_SIZE
    end
    return result
  end
end
