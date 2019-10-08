import macros, db_common, strutils

type ormOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  tryExec, getRow, getAllRows, getValue, tryInsertID, insertID, execAffectedRows, sql, sqlPrepared

template isQuestionChar(v: NimNode): bool = v.kind == nnkCharLit and v.intVal == 63

template sqlComment(comment: string): string =
  assert comment.len > 0, "SQL Comment must not be empty string"
  when defined(release): n
  else:
    if comment.countLines == 1: "-- " & $comment.strip & n
    else: "/* " & $comment.strip & " */" & n

template offsets(value: NimNode): string =
  doAssert value.kind in {nnkIntLit, nnkCharLit}, "OFFSET must be Natural or '?'"
  if isQuestionChar(value): "OFFSET ?" & n
  else: "OFFSET " & $value.intVal.Natural & n

template limits(value: NimNode): string =
  doAssert value.kind in {nnkIntLit, nnkCharLit}, "LIMIT must be Positive or '?'"
  if isQuestionChar(value): "LIMIT ?" & n
  else: "LIMIT " & $value.intVal.Positive & n

template froms(value: NimNode): string =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "FROM must be string or '?'"
  if isQuestionChar(value): "FROM ?" & n
  else: "FROM " & $value.strVal & n

template wheres(value: NimNode): string =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "WHERE must be string or '?'"
  if isQuestionChar(value): "WHERE ?" & n
  else: "WHERE " & $value.strVal & n

template orderbys(value: NimNode): string =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "ORDER BY must be string or '?'"
  if isQuestionChar(value): "ORDER BY ?" & n
  else:
    if value.strVal == "asc": "ORDER BY ASC" & n
    elif value.strVal == "desc": "ORDER BY DESC" & n
    else: "ORDER BY " & $value.strVal & n

template selects(value: NimNode): string =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "SELECT must be string or '?'"
  if isQuestionChar(value): "SELECT ?" & n
  elif value.kind == nnkCharLit: "SELECT *" & n
  else: "SELECT " & $value.strVal & n

template selects2(value: NimNode): string =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "SELECT must be string or '?'"
  if isQuestionChar(value): "SELECT DISTINCT ?" & n
  elif value.kind == nnkCharLit: "SELECT DISTINCT *" & n
  else: "SELECT DISTINCT " & $value.strVal & n


macro query*(output: ormOutput, inner: untyped): untyped =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL).
  const n = when defined(release): " " else: "\n"
  var sqls: string
  for node in inner:
    doAssert node.kind == nnkCommand, "Wrong Syntax on SQL DSL, must be nnkCommand"
    case normalize($node[0])
    of "--": sqls.add sqlComment($node[1])
    of "offset": sqls.add offsets(node[1])
    of "limit": sqls.add limits(node[1])
    of "from": sqls.add froms(node[1])
    of "where": sqls.add wheres(node[1])
    of "order", "orderby": sqls.add orderbys(node[1])
    of "select": sqls.add selects(node[1])
    of "selectdistinct": sqls.add selects2(node[1])
    else: doAssert false, inner.lineInfo
  assert sqls.len > 0, "Unknown error on SQL DSL, SQL Query must not be empty."
  sqls.add when defined(release): ";" else: "; /* " & inner.lineInfo & " */\n"
  when defined(dev): echo sqls
  sqls = case parseEnum[ormOutput]($output)
    of tryExec: "tryExec(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getRow: "getRow(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getAllRows: "getAllRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of getValue: "getValue(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of tryInsertID: "tryInsertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of insertID: "insertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of execAffectedRows: "execAffectedRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of sqlPrepared: # SqlPrepared for Postgres, sql""" query """ for SQLite.
      when defined(postgres): "prepare(db, \"" & inner.lineInfo.normalize & "\", sql(\"\"\"" & sqls & "\"\"\"), args.len)"
      else: "sql(\"\"\"" & sqls & "\"\"\")"
    else: "sql(\"\"\"" & sqls & "\"\"\")" # sql is sql""" query """ for SQLite
  # when defined(dev): echo sqls
  result = parseStmt sqls


when isMainModule:
  ############################### Compile-Time ################################
  # SQL Queries are Minified for Release builds, Pretty-Printed for Debug builds
  # DSL works on const/let/var, compile-time/run-time, JS/NodeJS, NimScript, C++
  const foo = query sql:
    select "foo, bar, baz"
    `from`"things"               # This can have comments here.
    where "cost > 30 or foo > 9" ## This can have comments here.
    offset 9
    `--`"SQL Style Comments"     # SQL Comments are stripped for Release builds.
    limit 1
    orderby "something"
  echo foo.string

  let bar = query sql: # Replace sql here with 1 of tryExec,getRow,getValue,etc
    selectdistinct "oneElementAlone"
    `from`'?'
    where "nim > 9000 and nimwc > 9000 or pizza <> NULL and answer =~ 42"
    offset '?'    # '?' produces ? on output to be replaced by values from args.
    limit '?'
    orderby '?'
  echo bar.string

  var baz = query sql: # Replace sql here with 1 of tryInsertID,sqlPrepared,etc
    select '*'         # '*' produces * on output to allow SELECT * FROM table
    `from`"stuffs"
    where "answer = 42 and power > 9000 or doge = ? and catto <> 666"
    offset 2147483647
    limit 2147483647
    orderby "asc"
  echo baz.string

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
