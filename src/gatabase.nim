## Gatabase: Compile-time lightweight ORM for Postgres or SQLite (SQL DSL).
import macros, db_common, strutils, tables
include gatabase/templates # Tiny compile-time internal templates that do 1 thing.

type ormOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  tryExec, getRow, getAllRows, getValue, tryInsertID, insertID, execAffectedRows, sql, sqlPrepared, anonFunc, exec

macro query*(output: ormOutput, inner: untyped): untyped =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL) https://u.nu/x5rz
  when not declared(db): {.hint: "'db' of type 'DbConn' must be declared for the ORM to work properly!".}
  const err0 = "Wrong Syntax, deep nested SubQueries are not supported yet, repeated call found"
  var offsetUsed, limitUsed, fromUsed, whereUsed, orderUsed, selectUsed, deleteUsed, likeUsed, valuesUsed,
    betweenUsed, joinUsed, groupbyUsed, havingUsed, intoUsed, insertUsed, isnullUsed, updateUsed: bool
  var sqls: string
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
      sqls.add values(node[1])
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
      offsetUsed = off # Union can "Reset" select,from,where,etc to be re-used
      limitUsed = off; fromUsed = off; whereUsed = off; orderUsed = off
      selectUsed = off; deleteUsed = off; likeUsed = off; valuesUsed = off
      betweenUsed = off; joinUsed = off; groupbyUsed = off; havingUsed = off
      intoUsed = off; insertUsed = off; isnullUsed = off; updateUsed = off
      sqls.add unions(node[1])
    of "case":
      isTable(node[1])
      sqls.add static(n & "(CASE" & n)
      for tableValue in node[1]:
        if tableValue[0].strVal == "default":
          sqls.add "  ELSE " & tableValue[1].strVal & n
        else:
          sqls.add "  WHEN " & tableValue[0].strVal & " THEN " & tableValue[1].strVal & n
      sqls.add static("END)" & n)
    of "set":
      isTable(node[1])
      var temp: seq[string]
      for tableValue in node[1]:
        temp.add tableValue[0].strVal & " = " & tableValue[1].strVal
      sqls.add "SET " & temp.join", "
    of "comment":
      isTable(node[1])
      when defined(postgres):
        var what, name, coment: string
        for tableValue in node[1]:
          if tableValue[0].strVal == "on":
            what = tableValue[1].strVal.strip
            doAssert what.len > 0, "COMMENT 'on' value must not be empty string"
          else:
            name = tableValue[0].strVal.strip
            coment = tableValue[1].strVal.strip
            doAssert name.len > 0, "COMMENT 'name' value must not be empty string"
        sqls.add "COMMENT ON " & what & " " & name & " IS '" & coment & "'" & n
    else: doAssert false, "Unknown syntax error on ORMs DSL: " & inner.lineInfo
  assert sqls.len > 0, "Unknown error on SQL DSL, SQL Query must not be empty."
  sqls.add when defined(release): ";" else: ";  /* " & inner.lineInfo & " */\n"
  when defined(dev): echo sqls
  sqls = case parseEnum[ormOutput]($output)
    of exec: "exec(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of tryExec: "tryExec(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getRow: "getRow(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getAllRows: "getAllRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getValue: "getValue(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of tryInsertID: "tryInsertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of insertID: "insertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of execAffectedRows: "execAffectedRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of anonFunc: "(func (): SqlQuery = sql(\"\"\"" & sqls & "\"\"\"))"
    of sqlPrepared: # SqlPrepared for Postgres, sql""" query """ for SQLite.
      when defined(postgres): # db_postgres.prepare() returns 1 SqlPrepared.
        "prepare(db, \"" & inner.lineInfo.normalize & "\", sql(\"\"\"" & sqls & "\"\"\"), args.len)"
      else: "sql(\"\"\"" & sqls & "\"\"\")" # SQLite wont support prepared.
    else: "sql(\"\"\"" & sqls & "\"\"\")" # sql is sql""" query """ for SQLite
  result = parseStmt sqls


#when isMainModule:
runnableExamples:

  const foo {.used.} = query sql:
    select "foo, bar, baz" # This can have comments here.
    `from`"things"
    where "cost > 30 or taxes > 9 and rank <> 0"
    offset 9
    `--`"SQL Style Comments. SQL Comments are stripped for Release builds."
    limit 1
    orderby "something"

  let bar {.used.} = query sql:
    `--`"Replace sql here ^ with 1 of tryExec,getRow,tryInsertID,sqlPrepared"
    selectdistinct "oneElementAlone"
    `from`'?'
    where "nim > 9000 and nimwc > 9000 or pizza <> NULL and answer =~ 42"
    `--`"The '?' produces ? on output, to be replaced by values from args."
    offset '?'
    limit '?'
    orderby '?'

  var baz {.used.} = query anonFunc:
    select '*'
    `--`"The '*' produces * on output to allow stuff like:  SELECT * FROM table"
    `from`"stuffs"
    where "answer = 42 and power > 9000 or doge = ? and catto <> 666"
    offset 2147483647
    limit 2147483647
    orderby "asc"

  let newfoo {.used.} = query sqlPrepared:
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
    values 9
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
