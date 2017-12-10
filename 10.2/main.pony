use "collections"
use "buffered"
use "itertools"
use "format"

class Notify is StdinNotify
  let _env: Env
  let _reader: Reader

  new create(env: Env) =>
    _env = env
    _reader = Reader

  fun ref apply(data: Array[U8] iso) =>
    _reader.append(consume data)

    try
      while true do
        let line = _reader.line()?
        let lengths: Array[U8] = Array[U8]
        var current: USize = 0
        var skip: USize = 0

        let numbers = Array[U32]
        for number in Range[U32](0, 256) do
          numbers.push(number)
        end

        lengths.concat(line.values())
        lengths.push(17)
        lengths.push(31)
        lengths.push(73)
        lengths.push(47)
        lengths.push(23)

        for round in Range(0, 64) do
          _env.out.print("Round: " + round.string())
          for length in lengths.values() do
            _env.out.print("Length: " + length.string() + ", current: " + current.string() + ", skip: " + skip.string())

            let cycled_numbers = Iter[U32](numbers.values()).cycle()
            let reversed1 = cycled_numbers.skip(current).take(length.usize())
            let reversed = Array[U32]
            for number in reversed1 do
              reversed.push(number)
            end
            reversed.reverse_in_place()

            for number in reversed.values() do
              numbers.update(current, number)?
              current = (current + 1) % numbers.size()
            end

            current = (current + skip) % numbers.size()
            skip = skip + 1
          end
        end

        let dense = Array[U32]
        for y in Range(0, 16) do
          var hash: U32 = 0
          for x in Range(0, 16) do
            hash = hash xor numbers((y*16)+x)?
          end
          dense.push(hash)
        end

        for hash in dense.values() do
          _env.out.write(Format.int[U32](hash where width = 2, fill = '0', fmt = FormatHexSmallBare))
        end
        _env.out.write("\n")

        _env.out.print("Product: " + (numbers(0)? * numbers(1)?).string())
      end
    end

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
