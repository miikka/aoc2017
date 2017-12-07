use "collections"
use "buffered"

class Notify is StdinNotify
  let _env: Env
  let _reader: Reader
  let _weights: Map[String, U32]
  let _children: Map[String, Array[String]]
  let _parents: Map[String, String]
  let _words: Array[String]

  new create(env: Env) =>
    _env = env
    _reader = Reader
    _words  = Array[String]
    _weights = Map[String, U32]
    _children = Map[String, Array[String]]
    _parents = Map[String, String]

  fun ref apply(data: Array[U8] iso) =>
    _reader.append(consume data)

    try
      while true do
        let line = _reader.line()?

        let parts = line.split(" ")
        let word = parts(0)?

        let weight = match parts(1)?.read_int[U32](1,10)?
        | (0, 0) =>
        error
        | (let value: U32, _) =>
        value
        end

        _words.push(word)
        _weights.update(word, weight)
        _children.update(word, Array[String])

        if parts.size() > 3 then
          for index in Range(3, parts.size()) do
            let child: String val = recover parts(index)?.clone().>strip(",") end
            _parents.update(child, word)
            _children(word)?.push(child)
          end
        end
      end
    end

  fun _weight(node: String): U32? =>
    var sum: U32 = _weights(node)?
    for child in _children(node)?.values() do
      sum = sum + _weight(child)?
    end
    sum

  fun _check(node: String)? =>
    let child_weights: Array[U32] = Array[U32]
    for child in _children(node)?.values() do
      child_weights.push(_weight(child)?)
    end

    if child_weights.size() > 0 then
      let freq: Map[U32, U32] = Map[U32, U32]

      for w in child_weights.values() do
        if freq.contains(w) then
          freq.update(w, freq(w)? + 1)
        else
          freq.update(w, 1)
        end
      end

      if freq.size() > 1 then
        var min_value: U32 = 0xFFFFFFFF
        var min_index: U32 = 0

        for (index, value) in freq.pairs() do
          if value < min_value then
            min_value = value
            min_index = index
          end
        end

        let child_index = child_weights.find(min_index)?
        let child = _children(node)?(child_index)?

        _env.out.print("Node " + node + " has a mismatch: problem child " + child)
        _env.out.print("Node " + child + " weight: " + _weights(child)?.string() + " full weight " + min_index.string())

        for weight in freq.keys() do
          _env.out.print("Weight: " + weight.string())
        end

        _check(child)?
      else
        _env.out.print("Node " + node + " okay.")
      end
    end

  fun ref dispose() =>
    try
      var root = ""

      for word in _words.values() do
        if not _parents.contains(word) then
          root = word
          break
        end
      end

      _env.out.print("Root: " + root + ", " + _weight(root)?.string())
      _check(root)?
    end



actor Main
  new create(env: Env) =>
    env.input(recover Notify(env) end, 1024)
