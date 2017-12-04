use "collections"

actor Main
  new create(env: Env) =>
    try
      var input = env.args(1)?
      match input.read_int[U32](0, 10)?
        | (0, 0) =>
        env.err.print("Bad value: " + input)
        | (let value: U32, _) =>
        env.out.print("Input: " + value.string())

        var s: I32 = 1
        var c1: I32 = 0
        var c2: I32 = 0
        var d: I32 = 0
        var x: I32 = 0
        var y: I32 = 0

        for i in Range(0, (value - 1).usize()) do
          match d
            | 0 => x = x + 1
            | 1 => y = y - 1
            | 2 => x = x - 1
            | 3 => y = y + 1
          end

          c1 = c1 + 1
          if c1 == s then
            c1 = 0
            c2 = c2 + 1
            d = (d + 1) % 4
            if c2 == 2 then
              s = s + 1
              c2 = 0
            end
          end

        end
        env.err.print("x = " + x.string() + ", y = " + y.string() + ", sum " + (x.abs()+y.abs()).string())
      end
    else
      env.err.print("No input")
    end
