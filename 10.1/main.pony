use "collections"
use "buffered"
use "itertools"

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
        let lengths: Array[U32] = Array[U32]
        var current: USize = 0
        var skip: USize = 0

        let numbers = Array[U32]
        for number in Range[U32](0, 256) do
          numbers.push(number)
        end

        for part in line.split(" \t,").values() do
          if part.size() == 0 then
            continue
          end

          match part.read_int[U32](0, 10)?
          | (0, 0) => _env.out.print("Bad part: " + part)
          | (let value: U32, _) => lengths.push(value)
          end
        end

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

        _env.out.print("Product: " + (numbers(0)? * numbers(1)?).string())
      end
    end

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
