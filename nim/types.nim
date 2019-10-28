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

# See: https://github.com/nim-lang/Nim/pull/1537/commits/9a9cadf0a4839527264145c1419549cd225c687b
type cconststring* {.importc: "const char *", nodecl.} = cstring


converter `cconststring->cstring`*(s: cconststring): cstring {.inline.} =
  ## Implicit conversion from ``cconststring`` to ``cstring``.
  cast[cstring](s)


converter `cstring->cconststring`*(s: cstring): cconststring {.inline.} =
  ## Implicit conversion from ``cconststring`` to ``cstring``.
  cast[cconststring](s)
