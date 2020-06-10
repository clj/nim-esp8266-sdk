# Based on https://create.stephan-brumme.com/crc32/#half-byte
# Which is published using the zlib License

let lut = [0x00000000'u32, 0x1DB71064'u32, 0x3B6E20C8'u32, 0x26D930AC'u32,
           0x76DC4190'u32, 0x6B6B51F4'u32, 0x4DB26158'u32, 0x5005713C'u32,
           0xEDB88320'u32, 0xF00F9344'u32, 0xD6D6A3E8'u32, 0xCB61B38C'u32,
           0x9B64C2B0'u32, 0x86D3D2D4'u32, 0xA00AE278'u32, 0xBDBDF21C'u32]


proc crc32*[T](data: var T, previous: uint32 = 0): uint32 =
  result = not previous
  let length = sizeof(data)
  var d: ptr UncheckedArray[char]
  var idx = 0
  d = cast[ptr UncheckedArray[char]](addr data)
  while idx < length:
    let current = uint32(d[idx])
    result = lut[(result xor current) and 0x0F] xor (result shr 4)
    result = lut[(result xor (current shr 4)) and 0x0F] xor (result shr 4)
    idx += 1
  result = not result
