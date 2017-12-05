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
        let tape = Array[I32]

        for line in FileLines(file) do
          match line.read_int[I32](0, 10)?
            | (0, 0) =>
            env.err.print("Bad line: " + line)
            | (let value: I32, _) =>
            tape.push(value)
          end
        end

        while true do
          let jump: I32 = tape(ip)?
          let next: I32 = ip.i32() + jump

          count = count + 1
          tape.update(ip, jump + 1)?

          if (next < 0) or (next >= tape.size().i32()) then
            break
          else
            ip = next.usize()
          end
        end

        env.out.print("Sum: " + count.string())
      else
        env.err.print("Error opening file " + file_name)
      end
    end
