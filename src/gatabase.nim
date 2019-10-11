## Gatabase: Compile-time lightweight ORM for Postgres or SQLite (SQL DSL).
import macros, db_common, strutils, tables
include gatabase/templates # Tiny compile-time internal templates that do 1 thing.

type GatabaseOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  TryExec, GetRow, GetAllRows, GetValue, TryInsertID, InsertID, ExecAffectedRows, Sql, Prepared, Func, Exec

macro query*(output: GatabaseOutput, inner: untyped): untyped =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL) https://u.nu/x5rz
  when not declared(db): {.hint: "'db' of type 'DbConn' must be declared for the ORM to work properly!".}
  const err0 = "Wrong Syntax, deep nested SubQueries are not supported yet, repeated call found"
  var
    offsetUsed, limitUsed, fromUsed, whereUsed, orderUsed, selectUsed,
      deleteUsed, likeUsed, valuesUsed, betweenUsed, joinUsed, groupbyUsed,
      havingUsed, intoUsed, insertUsed, isnullUsed, updateUsed: bool
    sqls: string
    args: NimNode
  for node in inner:
    doAssert node.kind == nnkCommand, "Wrong Syntax on DSL, must be nnkCommand"
    case normalize($node[0])
    of "--": sqls.add sqlComment($node[1])
    of "offset":
      doAssert not offsetUsed, err0
      sqls.add offsets(node[1])
      offsetUsed = true
    of "limit":
      doAssert not limitUsed, err0
      sqls.add limits(node[1])
      limitUsed = true
    of "values":
      doAssert not valuesUsed, err0
      sqls.add values(node[1].len)
      args = node[1]
      valuesUsed = true
    of "from":
      doAssert not fromUsed, err0
      sqls.add froms(node[1])
      fromUsed = true
    of "where":
      doAssert not whereUsed, err0
      sqls.add wheres(node[1])
      whereUsed = true
    of "wherenot":
      doAssert not whereUsed, err0
      sqls.add whereNots(node[1])
      whereUsed = true
    of "whereexists":
      doAssert not whereUsed, err0
      sqls.add whereExists(node[1])
      whereUsed = true
    of "wherenotexists":
      doAssert not whereUsed, err0
      sqls.add whereNotExists(node[1])
      whereUsed = true
    of "order", "orderby":
      doAssert not orderUsed, err0
      sqls.add orderbys(node[1])
      orderUsed = true
    of "select":
      doAssert not selectUsed, err0
      sqls.add selects(node[1])
      selectUsed = true
    of "selectdistinct":
      doAssert not selectUsed, err0
      sqls.add selectDistincts(node[1])
      selectUsed = true
    of "selecttop":
      doAssert not selectUsed, err0
      sqls.add selectTops(node[1])
      selectUsed = true
    of "selectmin":
      doAssert not selectUsed, err0
      sqls.add selectMins(node[1])
      selectUsed = true
    of "selectmax":
      doAssert not selectUsed, err0
      sqls.add selectMaxs(node[1])
      selectUsed = true
    of "selectcount":
      doAssert not selectUsed, err0
      sqls.add selectCounts(node[1])
      selectUsed = true
    of "selectavg":
      doAssert not selectUsed, err0
      sqls.add selectAvgs(node[1])
      selectUsed = true
    of "selectsum":
      doAssert not selectUsed, err0
      sqls.add selectSums(node[1])
      selectUsed = true
    of "delete":
      doAssert not deleteUsed, err0
      sqls.add deletes(node[1])
      deleteUsed = true
    of "like":
      doAssert not likeUsed and whereUsed, err0
      sqls.add likes(node[1])
      likeUsed = true
    of "notlike":
      doAssert not likeUsed and whereUsed, err0
      sqls.add notlikes(node[1])
      likeUsed = true
    of "between":
      doAssert not betweenUsed and whereUsed, err0
      sqls.add betweens(node[1])
      betweenUsed = true
    of "notbetween":
      doAssert not betweenUsed and whereUsed, err0
      sqls.add notbetweens(node[1])
      betweenUsed = true
    of "innerjoin":
      doAssert not joinUsed, err0
      sqls.add innerjoins(node[1])
      joinUsed = true
    of "leftjoin":
      doAssert not joinUsed, err0
      sqls.add leftjoins(node[1])
      joinUsed = true
    of "rightjoin":
      doAssert not joinUsed, err0
      sqls.add rightjoins(node[1])
      joinUsed = true
    of "fulljoin":
      doAssert not joinUsed, err0
      sqls.add fulljoins(node[1])
      joinUsed = true
    of "groupby", "group":
      doAssert not groupbyUsed, err0
      sqls.add groupbys(node[1])
      groupbyUsed = true
    of "having":
      doAssert not havingUsed, err0
      sqls.add havings(node[1])
      havingUsed = true
    of "into":
      doAssert not intoUsed, err0
      sqls.add intos(node[1])
      intoUsed = true
    of "insert", "insertinto":
      doAssert not insertUsed, err0
      sqls.add inserts(node[1])
      insertUsed = true
    of "isnull":
      doAssert not isnullUsed, err0
      sqls.add isnulls(node[1])
      isnullUsed = true
    of "update":
      doAssert not updateUsed, err0
      sqls.add updates(node[1])
      updateUsed = true
    of "union":
      resetAllGuards()
      sqls.add unions(node[1])
    of "case":
      sqls.add cases(node[1])
    of "set":
      sqls.add sets(node[1])
    of "comment":
      sqls.add comments(node[1])
    else: doAssert false, "Unknown syntax error on ORMs DSL: " & inner.lineInfo
  doAssert sqls.len > 0, "Unknown error on SQL DSL, SQL Query must not be empty."
  sqls.add when defined(release): ";" else: ";  /* " & inner.lineInfo & " */\n"
  when defined(dev): echo sqls
  let # This prepares the arguments from a Tuple into varargs "unpacked".
    y = if args.len > 0: $toStrLit(args) else: ""
    x = if y.len > 0: y[1..^2] else: y
  sqls = case parseEnum[GatabaseOutput]($output)
    of Exec: "exec(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of TryExec: "tryExec(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of GetRow: "getRow(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of GetAllRows: "getAllRows(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of GetValue: "getValue(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of TryInsertID: "tryInsertID(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of InsertID: "insertID(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of ExecAffectedRows: "execAffectedRows(db,sql(\"\"\"" & sqls & "\"\"\"), " & x & ")"
    of Func: "( func (): SqlQuery = sql( \"\"\"" & sqls & "\"\"\" ) )"
    of Prepared: # SqlPrepared for Postgres, sql""" query """ for SQLite.
      when defined(postgres): # db_postgres.prepare() returns 1 SqlPrepared.
        "prepare(db,\"" & inner.lineInfo.normalize & "\",sql(\"\"\"" & sqls & "\"\"\")," & $args.len & ")"
      else: "sql(\"\"\"" & sqls & "\"\"\")" # SQLite wont support prepared.
    else: "sql(\"\"\"" & sqls & "\"\"\")" # sql is sql""" query """ for SQLite
  # when defined(dev): echo sqls
  result = parseStmt sqls


# when isMainModule:
runnableExamples:

  const foo {.used.} = query Sql:
    select "foo, bar, baz" # This can have comments here.
    `from`"things"
    where "cost > 30 or taxes > 9 and rank <> 0"
    offset 9
    `--`"SQL Style Comments. SQL Comments are stripped for Release builds."
    limit 1
    orderby "something"

  let bar {.used.} = query Sql:
    `--`"Replace sql here ^ with 1 of tryExec,getRow,tryInsertID,sqlPrepared"
    selectdistinct "oneElementAlone"
    `from`'?'
    where "nim > 9000 and nimwc > 9000 or pizza <> NULL and answer =~ 42"
    `--`"The '?' produces ? on output, to be replaced by values from args."
    offset '?'
    limit '?'
    orderby '?'

  var baz {.used.} = query Func:
    select '*'
    `--`"The '*' produces * on output to allow stuff like:  SELECT * FROM table"
    `from`"stuffs"
    where "answer = 42 and power > 9000 or doge = ? and catto <> 666"
    offset 2147483647
    limit 2147483647
    orderby "asc"

  let newfoo {.used.} = query Prepared:
    `--`"More advanced stuff for more complex database queries"
    delete "debts"
    where "debt > 99"
    notlike "boss"
    notbetween "666 and 999"
    innerjoin "something"
    groupby "taxes"
    `--`"DSL works on const/let/var,compile-time/run-time,JS/NodeJS,NimScript"
    having "currency"
    into "dsfsdfd"
    insert "happiness"
    isnull true
    update "table"
    union true
    comment {"on": "TABLE", "myTable": "This is an SQL COMMENT on a TABLE"}
    `set` {"key0": "true", "key1": "false", "key2": "NULL", "key3": "NULL"}
    `case` {"foo > 9": "true", "bar == 42": "false", "default": "NULL"}
    `--`"Query is Minified for Release builds, Pretty-Printed for Debug builds"


  # when not defined(js): # This wont work on NimScript, because no db_sqlite.
  #   import db_sqlite # `db: DbConn` and `args: varargs` must exist previously.
  #   let db = db_sqlite.open(":memory:", "", "", "") # Just for demostrations.
  #   const args = ["args", "and", "db", "variables", "must", "exist"] # Fake args.

  #   let runTime_tryExec {.used.} = query tryExec:
  #     select '*'
  #     `from`'?'
  #     where "costs > 9 or rank > 1 and level < 99"
  #     offset 0
  #     limit 1
  #     orderby "asc"

  #   let runTime_tryInsertID {.used.} = query tryInsertID:
  #     select '*'
  #     `from`'?'
  #     where "foo > 1 and foo < 9 and foo <> 42"
  #     offset 1
  #     limit 2147483647
  #     orderby "desc"
