use "collections"
use "buffered"

class Notify is StdinNotify
  let _env: Env
  let _reader: Reader
  let _registers: Map[String, I32]
  var _highest: I32

  new create(env: Env) =>
    _env = env
    _reader = Reader
    _registers = Map[String, I32]
    _highest = I32.min_value()

  fun ref apply(data: Array[U8] iso) =>
    _reader.append(consume data)

    try
      while true do
        let line = _reader.line()?
        let parts = line.split(" ")

        let register = parts(0)?
        let sign: I32 = if parts(1)? == "inc" then 1 else -1 end

        let delta: I32 = match parts(2)?.read_int[I32](0,10)?
        | (0, 0) => error
        | (let value: I32, _) => sign * value
        end

        let source = parts(4)?
        let predicate = parts(5)?
        let target: I32 = match parts(6)?.read_int[I32](0,10)?
        | (0, 0) => error
        | (let value: I32, _) => value
        end

        let current = _registers.get_or_else(source, 0)
        let condition: Bool = match predicate
        | ">" => current > target
        | "<" => current < target
        | ">=" => current >= target
        | "<=" => current <= target
        | "==" => current == target
        | "!=" => current != target
        else
          error
        end

        if condition then
          let new_value = _registers.insert(register, _registers.get_or_else(register, 0) + delta)?
          if new_value > _highest then
            _highest = new_value
          end
        end
      end
    end

  fun ref dispose() =>
    var max_value: I32 = I32.min_value()

    for (register, value) in _registers.pairs() do
      _env.out.print("Register: " + register + ", value: " + value.string())
      if value > max_value then
        max_value = value
      end
    end

    _env.out.print("Maximum value: " + max_value.string())
    _env.out.print("Highest value: " + _highest.string())


actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
