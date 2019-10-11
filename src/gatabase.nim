## **Gatabase:** Compile-time lightweight ORM for Postgres or SQLite (SQL DSL).
import macros
include gatabase/templates # Tiny compile-time internal templates that do 1 thing.

type GatabaseOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  TryExec, GetRow, GetAllRows, GetValue, TryInsertID, InsertID, ExecAffectedRows, Sql, Prepared, Func, Exec

macro query*(output: GatabaseOutput, inner: untyped): untyped =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL) https://u.nu/x5rz
  when not defined(release) and not defined(danger) and not declared(db):
    {.hint: "'db' of type 'DbConn' must be declared for the ORM to work properly!".}
  var
    offsetUsed, limitUsed, fromUsed, whereUsed, orderUsed, selectUsed,
      deleteUsed, likeUsed, valuesUsed, betweenUsed, joinUsed, groupbyUsed,
      havingUsed, intoUsed, insertUsed, isnullUsed, updateUsed: bool
    sqls: string
    args: NimNode
  const err0 = "Wrong Syntax, nested SubQueries not supported, repeated call found. "
  for node in inner:
    doAssert node.kind == nnkCommand, "Wrong Syntax on DSL, must be nnkCommand"
    case $node[0]
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
      doAssert selectUsed or deleteUsed, err0 & "FROM without SELECT nor DELETE"
      sqls.add froms(node[1])
      fromUsed = true
    of "where":
      doAssert not whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      WHERE without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add wheres(node[1])
      whereUsed = true
    of "wherenot":
      doAssert not whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      WHERE NOT without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add whereNots(node[1])
      whereUsed = true
    of "whereexists":
      doAssert not whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      WHERE EXISTS without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add whereExists(node[1])
      whereUsed = true
    of "wherenotexists":
      doAssert not whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      WHERE NOT EXISTS without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add whereNotExists(node[1])
      whereUsed = true
    of "order", "orderby":
      doAssert not orderUsed, err0
      doAssert selectUsed, err0 & "ORDER BY without SELECT"
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
    of "delete":
      doAssert not deleteUsed, err0
      sqls.add deletes(node[1])
      deleteUsed = true
    of "like":
      doAssert not likeUsed and whereUsed, err0
      doAssert selectUsed or whereUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      LIKE without WHERE nor SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add likes(node[1])
      likeUsed = true
    of "notlike":
      doAssert not likeUsed and whereUsed, err0
      doAssert selectUsed or whereUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      NOT LIKE without WHERE nor SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add notlikes(node[1])
      likeUsed = true
    of "between":
      doAssert not betweenUsed and whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      BETWEEN without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add betweens(node[1])
      betweenUsed = true
    of "notbetween":
      doAssert not betweenUsed and whereUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      NOT BETWEEN without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add notbetweens(node[1])
      betweenUsed = true
    of "groupby", "group":
      doAssert not groupbyUsed, err0
      doAssert selectUsed, err0 & "GROUP BY without SELECT"
      sqls.add groupbys(node[1])
      groupbyUsed = true
    of "into":
      doAssert not intoUsed, err0
      sqls.add intos(node[1])
      intoUsed = true
    of "insert", "insertinto":
      doAssert not insertUsed, err0
      sqls.add inserts(node[1])
      insertUsed = true
    of "update":
      doAssert not updateUsed, err0
      sqls.add updates(node[1])
      updateUsed = true
    of "set":
      {.linearScanEnd.} # https://nim-lang.github.io/Nim/manual.html#pragmas-linearscanend-pragma
      doAssert updateUsed, err0 & "SET without UPDATE"
      sqls.add sets(node[1]) # Below put the less frequently used case branches.
    of "having":
      doAssert not havingUsed, err0
      doAssert groupbyUsed, err0 & "HAVING without GROUP BY"
      sqls.add havings(node[1])
      havingUsed = true
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
    of "union":
      resetAllGuards()
      sqls.add unions(node[1])
    of "isnull":
      doAssert not isnullUsed, err0
      doAssert selectUsed or insertUsed or updateUsed or deleteUsed, err0 & """
      IS NULL without SELECT nor INSERT nor UPDATE nor DELETE"""
      sqls.add isnulls(node[1])
      isnullUsed = true
    of "innerjoin":
      doAssert not joinUsed, err0
      doAssert selectUsed, err0 & "INNER JOIN without SELECT"
      sqls.add innerjoins(node[1])
      joinUsed = true
    of "leftjoin":
      doAssert not joinUsed, err0
      doAssert selectUsed, err0 & "LEFT JOIN without SELECT"
      sqls.add leftjoins(node[1])
      joinUsed = true
    of "rightjoin":
      doAssert not joinUsed, err0
      doAssert selectUsed, err0 & "RIGHT JOIN without SELECT"
      sqls.add rightjoins(node[1])
      joinUsed = true
    of "fulljoin":
      doAssert not joinUsed, err0
      doAssert selectUsed, err0 & "FULL JOIN without SELECT"
      sqls.add fulljoins(node[1])
      joinUsed = true
    of "case": sqls.add cases(node[1])
    of "commentoncolumn": sqls.add comments(node[1], "COLUMN")
    of "commentondatabase": sqls.add comments(node[1], "DATABASE")
    of "commentonfunction": sqls.add comments(node[1], "FUNCTION")
    of "commentonindex": sqls.add comments(node[1], "INDEX")
    of "commentontable": sqls.add comments(node[1], "TABLE")
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
    else: "sql(\"\"\"" & sqls & "\"\"\")" # Sql is sql""" query """ for SQLite
  # when defined(dev): echo sqls
  result = parseStmt sqls
