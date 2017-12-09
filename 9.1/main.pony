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
        var depth: I32 = 0
        var score: I32 = 0
        var garbage: I32 = 0
        var state: String = "group"

        let line = _reader.line()?
        for char in line.values() do
          match (state, char)
            | ("group", '<') => state = "garbage"
            | ("group", '{') => depth = depth +1
            | ("group", '}') =>
              score = score + depth
              depth = depth - 1
            | ("group", ',') => None
            | ("garbage", '!') => state = "ignore"
            | ("garbage", '>') => state = "group"
            | ("garbage", _) => garbage = garbage + 1
            | ("ignore", _) => state = "garbage"
          else
            _env.out.print("Bad state and char: " + state + " " + char.string())
            error
          end
        end

        _env.out.print("Score: " + score.string() + ", garbage depth: " + garbage.string())
      end
    end

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
