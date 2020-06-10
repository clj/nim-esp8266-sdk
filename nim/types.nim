import macros

###
# See: http://forum.nim-lang.org/t/2337
###
macro section*(param: string, body: untyped) =
  let sectionName = strVal(if param.kind == nnkSym: param.getImpl() else: param)
  let codegenAttribute = "$# __attribute__((section(\"" & sectionName & "\"))) $#$#"

  body.addPragma(newNimNode(nnkExprColonExpr).add(newIdentNode("codegenDecl"),
                                              newStrLitNode(codegenAttribute)))

  return body


const
  SECTION_ROM* = ".irom0.text"
  SECTION_RODATA* = ".irom.text"
  SECTION_RAM* = ".iram.text"

# See: https://github.com/nim-lang/Nim/pull/1537/commits/9a9cadf0a4839527264145c1419549cd225c687b
type cconststring* {.importc: "const char *", nodecl.} = cstring


converter `cconststring->cstring`*(s: cconststring): cstring {.inline.} =
  ## Implicit conversion from ``cconststring`` to ``cstring``.
  cast[cstring](s)


converter `cstring->cconststring`*(s: cstring): cconststring {.inline.} =
  ## Implicit conversion from ``cconststring`` to ``cstring``.
  cast[cconststring](s)


template setString*[N, T: uint8 | byte | char](dst: var array[N, T], src: static string) =
  when len(src) > len(dst):
    {.error: "length of value '" & src & "' (" & $len(src) & ") does not fit in destnation array of lenth: " & $len(dst) .}
  dst = toArray(src, len(dst), T)


proc setString*[N, T: uint8 | byte | char](dst: var array[N, T], src: string) =
  for i in 0..<len(src):
    dst[i] = T(src[i])
  for i in len(src)..<len(dst):
    dst[i] = 0


macro toArray*(str: static string, length: static int, dstType: typed = char): untyped =
  result = nnkBracket.newTree()
  for ch in str:
    let node = nnkCall.newTree(
        dstType,
        newLit(ch)
      )
    result.add(node)
  for _ in 0..(length - len(str) - 1):
    let node = nnkCall.newTree(
        dstType,
        newLit('\0')
      )
    result.add(node)
