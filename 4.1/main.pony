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
          let word_set = Set[String]()

          var ok = true
          for part in line.split(" \t").values() do
            if part.size() == 0 then
              continue
            end

            if word_set.contains(part) then
              ok = false
              break
            end

            word_set.set(part)
          end

          if ok then
            sum = sum + 1
          end
        end
        env.out.print("Sum: " + sum.string())
      else
        env.err.print("Error opening file " + file_name)
      end
    end
