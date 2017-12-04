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
        try
          let chars = file.read(2048)
          var sum: U32 = 0
          let half = chars.size() / 2

          env.out.print("Size: " + chars.size().string() + ", half: " + half.string())

          for index in Range(0, chars.size()) do
            let char = chars(index)?
            let other = chars((index + half) % chars.size())?

            if (char < 48) or (char > 57) then
              env.err.print("Char out of range " + char.string() + " at index " + index.string())
            end

            if char == other then
              sum = sum + (char.u32() - 48)
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
