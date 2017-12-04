use "files"

actor Main
  new create(env: Env) =>
    try
      var file_name = env.args(1)?
      env.out.print("Input file: " + file_name)

      let path = FilePath(env.root as AmbientAuth, file_name)?
      match OpenFile(path)
        | let file: File =>
        var sum: U32 = 0
        for line in FileLines(file) do

          var min: U32 = 0xFFFFFFFF
          var max: U32 = 0

          for part in line.split(" \t").values() do
            if part.size() == 0 then
              continue
            end
            try
              match part.read_int[U32](0, 10)?
                | (0, 0) =>
                env.err.print("Bad part: " + part)
                | (let value: U32, _) =>
                if value < min then
                  min = value
                end
                if value > max then
                  max = value
                end
              end
            else
              env.err.print("Bad part: " + part)
            end
          end

          let diff = max - min
          env.out.print("Diff: " + diff.string())
          sum = sum + diff
        end
        env.out.print("Sum: " + sum.string())
      else
        env.err.print("Error opening file " + file_name)
      end
    end
