## Gatabase: Compile-time lightweight ORM for Postgres or SQLite (SQL DSL).
import macros, db_common, strutils, tables
include gatabase/templates # Tiny compile-time internal templates that do 1 thing.

type ormOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  tryExec, getRow, getAllRows, getValue, tryInsertID, insertID, execAffectedRows, sql, sqlPrepared, anonFunc

macro query*(output: ormOutput, inner: untyped): untyped =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL) https://u.nu/x5rz
  when not declared(db): {.hint: "'db' of type 'DbConn' must be declared for the ORM to work properly!".}
  const err0 = "Wrong Syntax, deep nested SubQueries are not supported yet, repeated call found"
  var offsetUsed, limitUsed, fromUsed, whereUsed, orderUsed, selectUsed, deleteUsed, likeUsed,
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
      fromUsed = false # Union can "Reset" select, from, where to be re-used
      whereUsed = false
      selectUsed = false
      likeUsed = false
      betweenUsed = false
      sqls.add unions(node[1])
    of "case":
      doAssert node[1].kind in {nnkTableConstr}, "CASE argument must be Table"
      doAssert node[1].len > 0, "CASE argument must be 1 Non Empty Table"
      sqls.add static("(CASE" & n)
      for tableValue in node[1]:
        if tableValue[0].strVal == "default":
          sqls.add "  ELSE " & tableValue[1].strVal & n
        else:
          sqls.add "  WHEN " & tableValue[0].strVal & " THEN " & tableValue[1].strVal & n
      sqls.add static("END)" & n)
    else: doAssert false, "Unknown syntax error on ORMs DSL: " & inner.lineInfo
  assert sqls.len > 0, "Unknown error on SQL DSL, SQL Query must not be empty."
  sqls.add when defined(release): ";" else: ";  /* " & inner.lineInfo & " */\n"
  when defined(dev): echo sqls
  sqls = case parseEnum[ormOutput]($output)
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
      else: "sql(\"\"\"" & sqls & "\"\"\")"  # SQLite wont support prepared.
    else: "sql(\"\"\"" & sqls & "\"\"\")" # sql is sql""" query """ for SQLite
  result = parseStmt sqls


when isMainModule:
  ############################### Compile-Time ################################
  # SQL Queries are Minified for Release builds, Pretty-Printed for Debug builds
  # DSL works on const/let/var, compile-time/run-time, JS/NodeJS, NimScript, C++
  const foo {.used.} = query sql:
    select "foo, bar, baz"
    `from`"things"               # This can have comments here.
    where "cost > 30 or foo > 9" ## This can have comments here.
    offset 9
    `--`"SQL Style Comments"     # SQL Comments are stripped for Release builds.
    limit 1
    orderby "something"

  let bar {.used.} = query sql: # Replace sql here with 1 of tryExec,getRow,getValue,etc
    selectdistinct "oneElementAlone"
    `from` '?'
    where "nim > 9000 and nimwc > 9000 or pizza <> NULL and answer =~ 42"
    offset '?'         # '?' produces ? on output to be replaced by values from args.
    limit '?'
    orderby '?'

  var baz {.used.} = query anonFunc: # Replace sql here with 1 of tryInsertID,sqlPrepared,etc
    select '*'              # '*' produces * on output to allow SELECT * FROM table
    `from` "stuffs"
    where "answer = 42 and power > 9000 or doge = ? and catto <> 666"
    offset 2147483647
    limit 2147483647
    orderby "asc"

  const newfoo {.used.} = query sql:
    delete "deletor"
    where "dfgdf"
    notlike "sds"
    notbetween "dfd"
    innerjoin "fdsf"
    groupby "dsfsdf32432"
    having "sd;fsd;lfkl;k"
    into "dsfsdfd"
    insert "dffd"
    isnull true
    update "sdsad"
    union true
    `case` {"foo > 9": "true", "bar == 42": "false", "default": "NULL"}
    #like "sdsd"

  # ################################## Run-Time #################################
  # import db_sqlite  # `db: DbConn` and `args: varargs` must exist previously.
  # let db = db_sqlite.open(":memory:", "", "", "")  # Just for demostrations.
  # const args = ["args", "and", "db", "must", "be", "on", "pre-existing", "variables"]

  # let runTimeTryQuery = query tryExec:
  #   select('?')
  #   `from`'?'
  #   where("cost > 30", "foo > 9")
  #   offset 9223372036854775807
  #   limit 9223372036854775807
  #   order by asc
  # echo runTimeTryQuery

  # let runTimeQuery = query tryInsertID:
  #   select('?')
  #   `from`'?'
  #   where("cost > 30", "foo > 9")
  #   offset 9223372036854775807
  #   limit 9223372036854775807
  #   order by asc
  # echo runTimeQuery


  # Copied from https://github.com/Araq/ormin/blob/master/examples/forum/forum.nim
  # let threads = query sql:
  #   select(id, name, views, modified)
  #   `from` thread
  #   where id in (select post(thread) where author in
  #       (select person(id) where status notin ("Spammer") or id == ?id))
  #   order by desc(modified)
  #   limit 9
  #   offset 42

  # let thisThread = query sql:
  #   select(id)
  #   `from` thread
  #   where("id == 42")
  # echo thisThread.string

  # query:
  #   delete antibot
  #   where ip == ?ip

  # query:
  #   insert antibot(?ip, ?answer)

  # let something = query:
  #   select antibot(answer & answer, (if ip == "hi": 0 else: 1))
  #   where ip == ?ip and answer =~ "%things%"
  #   orderby desc(ip)
  #   limit 1

  # let myNewPersonId: int = query:
  #   insert person(?name, password = ?pw, ?email, ?salt, status = !!"'EmailUnconfirmed'",
  #         lastOnline = !!"DATETIME('now')")
  #   returning id

  # query:
  #   delete session
  #   where ip == ?ip and password == ?pw

  # query:
  #   update session(lastModified = !!"DATETIME('now')")
  #   where ip == ?ip and password == ?pw

  # let myj = %*{"pw": "stuff here"}

  # let userId1 = query:
  #   select session(userId)
  #   where ip == ?ip and password == %myj["pw"]

  # let (name9, email9, status, ban) = query:
  #   select person(name, email, status, ban)
  #   where id == ?id
  #   limit 1

  # let (idg, nameg, pwg, emailg, creationg, saltg, statusg, lastOnlineg, bang) = query:
  #   select person(_)
  #   where id == ?id
  #   limit 1

  # query:
  #   update person(lastOnline = !!"DATETIME('now')")
  #   where id == ?id

  # query:
  #   update thread(views = views + 1, modified = !!"DATETIME('now')")
  #   where id == ?id

  # query:
  #   delete thread
  #   where id notin (select post(thread))

  # let (author, creation) = query:
  #   select post(author)
  #   join person(creation)
  #   limit 1

  # let (authorB, creationB) = query:
  #   select post(author)
  #   join person(creation) on author == id
  #   limit 1

  # let allPosts = query:
  #   select post(count(_) as cnt)
  #   where cnt > 0
  #   produce json
  #   limit 1

  # createProc getAllThreadIds:
  #   select thread(id)
  #   where id == ?id
  #   produce json

  # let totalThreads = query:
  #   select thread(count(_))
  #   where id in (select post(thread) where author == ?id and id in (
  #     select post(min(id)) groupby thread))
  #   limit 1


  # # https://github.com/Araq/ormin/blob/master/examples/chat/server.nim#L25
  # let lastMessages = query:
  #   select messages(content, creation, author)
  #   join users(name)
  #   orderby desc(creation)
  #   limit 100

  # query:
  #   update users(lastOnline = !!"DATETIME('now')")
  #   where id == ?userId

  # let lastMessage = query:
  #   select messages(content, creation, author)
  #   join users(name)
  #   orderby desc(creation)
  #   limit 1

  # var candidates = query:
  #   produce nim
  #   select users(id, password)
  #   where name == %arg["name"]

  # let userId = query:
  #   produce nim
  #   insert users(name = %arg["name"], password = %arg["password"])
  #   returning id
