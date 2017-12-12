use "collections"
use "buffered"

class Notify is StdinNotify
  let _env: Env
  let _reader: Reader
  let _adjacent: Map[String, Set[String]]

  new create(env: Env) =>
    _env = env
    _reader = Reader

    _adjacent = Map[String, Set[String]]

  fun ref apply(data: Array[U8] iso) =>
    _reader.append(consume data)

    try
      while true do
        let line = _reader.line()?
        let parts = line.split(" \t,")

        let source = parts(0)?
        let source_adjacent = _adjacent.insert_if_absent(source, Set[String])?

        for index in Range(2, parts.size()) do
          let target = parts(index)?

          if target.size() == 0 then
            continue
          end

          _adjacent(source)?.set(target)
          _adjacent.insert_if_absent(target, Set[String])?.set(source)
        end
      end
    end

   fun ref dispose() =>
     if _reader.size() > 0 then
       apply(recover "\n".array().clone() end)
     end

     let nodes = Set[String]
     for node in _adjacent.keys() do
       nodes.set(node)
     end

     var count: U32 = 0

     try
       while nodes.size() > 0 do
         let start = nodes.index(nodes.next_index()?)?
         let queue = [start]
         let visited = Set[String]

         _env.out.print("Starting from " + start)

         while queue.size() > 0 do
           let current = queue.shift()?
           if visited.contains(current) then
             continue
           else
             _env.out.print("Visiting " + current)
             queue.concat(_adjacent(current)?.values())
             visited.set(current)
           end
         end

         _env.out.print("Visited in total: " + visited.size().string())
         nodes.remove(visited.values())
         count = count + 1
       end
     end

     _env.out.print("Group count: " + count.string())

actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
