use "files"

actor Main
  new create(env: Env) =>
    try
      var file_name = env.args(1)?
      env.out.print("Input file: " + file_name)

      let path = FilePath(env.root as AmbientAuth, file_name)?
      match OpenFile(path)
        | let file: File =>
        try
          let first = file.read(1)(0)?
          var prev = first
          var sum: U32 = 0
          var ac: U32 = 0
          while file.errno() is FileOK do
            let arr = file.read(1)
            if arr.size() > 0 then
              let char = arr(0)?
              if char == prev then
                sum = sum + (char.u32() - 48)
              end
              prev = char
            else
              if prev == first then
                sum = sum + (prev.u32() - 48)
              end
            end
          end
          env.out.print("Sum: " + sum.string())
        else
          env.err.print("Eh")
        end
      else
        env.err.print("Error opening file " + file_name)
      end
    end
