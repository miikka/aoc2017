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
        var count: I32 = 0
        var score: I32 = 0
        var garbage: I32 = 0
        var mode: String = "base"

        let line = _reader.line()?
        for char in line.values() do
          match mode
            | "base" =>
            match char
              | '<' => mode = "garbage"
              | '{' => count = count + 1
              | '}' =>
              score = score + count
              count = count - 1
            end
            | "garbage" =>
            match char
              | '!' => mode = "ignore"
              | '>' => mode = "base"
            else
              garbage = garbage + 1
            end
            | "ignore" => mode = "garbage"
          else
            _env.out.print("Bad mode: " + mode)
            error
          end
        end

        _env.out.print("Score: " + score.string() + ", garbage count: " + garbage.string())
      end
    end

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
