import macros, sequtils

macro impl*(t: typedesc, body: untyped{nkStmtList}) =
  ## inserts `this: t` as first argument to every proc
  result = newStmtList()

  for x in body:
    result.add case x.kind
    of nnkProcDef, nnkFuncDef, nnkIteratorDef, nnkConverterDef, nnkTemplateDef, nnkMacroDef:
      let pragmas = x.pragma.filterit(it.kind == nnkIdent).mapit(it.strVal)
      x.params.insert 1, newIdentDefs(
        ident"this",
        if "ctor" in pragmas or "mut" in pragmas:
          nnkVarTy.newTree t
        else: t
      )
      if "mut" in pragmas:
        let i = x.pragma.find(ident"mut")
        x.pragma.del i
      x
    else: x

macro ctor*(body: untyped{nkProcDef|nkFuncDef|nkTemplateDef|nkMacroDef}) =
  ## creates T.procname(args...) for procname(this: var T, args...)
  
  let t =
    if body.params[1][1].kind == nnkVarTy: body.params[1][1][0]
    else: body.params[1][1]
  
  newStmtList(
    body,
    nnkProcDef.newTree(
      body[0],
      newEmptyNode(),
      body[2],
      nnkFormalParams.newTree(
        @[t] & @[newIdentDefs(genSym(nskParam), nnkBracketExpr.newTree(ident"typedesc", t))] & body.params[2..^1]
      ),
      newEmptyNode(),
      newEmptyNode(),
      newStmtList(
        newCall(
          if body[0].kind == nnkPostfix: body[0][1] else: body[0],
          @[ident"result"] & body.params[2..^1].mapit(it[0..^3]).concat
        )
      )
    )
  )
