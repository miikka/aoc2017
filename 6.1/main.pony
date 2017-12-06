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

        var count: U32 = 0
        var ip: USize = 0
        let tape = recover Array[U8] end

        for line in FileLines(file) do
          for part in line.split(" \t").values() do
            if part.size() == 0 then
              continue
            end

            match part.read_int[U8](0, 10)?
              | (0, 0) =>
              env.err.print("Bad line: " + line)
              | (let value: U8, _) =>
              tape.push(value)
            end
          end
        end

        let seen = Map[String, U32]

        while true do
          var max_index: USize = 0
          var max_value: U8 = 0

          for index in Range(0, tape.size()) do
            env.out.print(tape(index)?.string())
          end

          for index in Range(0, tape.size()) do
            let value = tape(index)?
            if value > max_value then
              max_index = index
              max_value = value
            end
          end

          env.out.print("Max value " + max_value.string() + ", max index " + max_index.string())

          tape.update(max_index, 0)?
          for n in Range(1, max_value.usize() + 1) do
            let position = (max_index + n) % tape.size()
            let old_value: U8 = tape(position)?
            tape.update(position, old_value + 1)?
          end

          count = count + 1
          env.out.print("Count: " + count.string())

          let tape_string: String val = recover
          let s = String
          for index in Range(0, tape.size()) do
            s.push(tape(index)?)
          end
          s
          end

          env.out.print("Set size " + seen.size().string())
          if seen.contains(tape_string) then
            env.out.print("Contains a string! Cycle: " + (count - seen(tape_string)?).string())
            break
          end
          seen.update(tape_string, count)
        end

        env.out.print("Sum: " + count.string())
      else
        env.err.print("Error opening file " + file_name)
      end
    end
