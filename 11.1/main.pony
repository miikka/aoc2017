use "collections"
use "buffered"

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

        var x: I32 = 0
        var y: I32 = 0
        var z: I32 = 0

        var max_distance: U32 = 0

        for part in line.split(" \t,").values() do
          if part.size() == 0 then
            continue
          end

          (x, y, z) = match part
          | "s"  => (x,     y - 1, z + 1)
          | "sw" => (x - 1, y,     z + 1)
          | "nw" => (x - 1, y + 1, z)
          | "n"  => (x,     y + 1, z - 1)
          | "ne" => (x + 1, y,     z - 1)
          | "se" => (x + 1, y - 1, z)
          else
            _env.out.print("Bad part: " + part)
            error
          end

          max_distance = max_distance.max(x.abs().max(y.abs().max(z.abs())))
        end

        let distance = x.abs().max(y.abs().max(z.abs()))
        _env.out.print("Coordinates: " + x.string() + ", " + y.string() + ", " + z.string())
        _env.out.print("Distance: " + distance.string())
        _env.out.print("Max distance: " + max_distance.string())
      end
    end

   fun ref dispose() =>
     if _reader.size() > 0 then
       apply(recover "\n".array().clone() end)
     end

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
