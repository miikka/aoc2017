use "collections"
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
          var numbers = Array[U32]()

          for part in line.split(" \t").values() do
            if part.size() == 0 then
              continue
            end
            try
              match part.read_int[U32](0, 10)?
                | (0, 0) =>
                env.err.print("Bad part: " + part)
                | (let value: U32, _) =>
                numbers.push(value)
              end
            else
              env.err.print("Bad part: " + part)
            end
          end

          try
            for idx1 in Range(0, numbers.size()) do
              for idx2 in Range(idx1 + 1, numbers.size()) do
                let num1: U32 = numbers(idx1)?
                let num2: U32 = numbers(idx2)?
                if ((num1 % num2) == 0) or ((num2 % num1) == 0) then
                  env.out.print("N " + num1.string() + ", " + num2.string())
                  sum = sum + (num1.max(num2) / num1.min(num2))
                end
              end
            end
          end
        end
        env.out.print("Sum: " + sum.string())
      else
        env.err.print("Error opening file " + file_name)
      end
    end
