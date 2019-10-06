import macros, db_common

type ormOutput* = enum ## All outputs of ORM, some compile-time, some run-time.
  tryExec, getRow, getAllRows, getValue, tryInsertID, insertID, execAffectedRows, sql

template isQuestionChar(n: NimNode): bool = n.kind == nnkCharLit and n.intVal == 63
template isAsteriskChar(n: NimNode): bool = n.kind == nnkCharLit and n.intVal == 42

macro query*(output: ormOutput, inner: untyped): auto =
  ## Compile-time lightweight ORM for Postgres/SQLite (SQL DSL).
  const n = when defined(release): " " else: "\n"
  const errWrongSql = "Gatabase Compile-Time ORM found 1 wrong SQL Syntax: "
  var sqls: string
  for node in inner:
    case node.kind
    of nnkCommand:
      case $node[0]
      of "offset":
        assert node.len == 2, errWrongSql & "offset Positive " & node.lineInfo
        if isQuestionChar(node[1]):
          sqls.add "OFFSET ?" & n
        else:
          sqls.add "OFFSET " & $node[1].intVal.Positive & n
      of "limit":
        assert node.len == 2, errWrongSql & "limit Positive " & node.lineInfo
        if isQuestionChar(node[1]):
          sqls.add "LIMIT ?" & n
        else:
          sqls.add "LIMIT " & $node[1].intVal.Positive & n
      of "order":
        assert node.len == 2, errWrongSql & "order by " & node.lineInfo
        assert $node[1][0] == "by", errWrongSql & "order by"
        if isQuestionChar(node[1][1]):
          sqls.add "ORDER BY ?" & n
        else:
          sqls.add "ORDER BY " & $node[1][1] & n
      of "from":
        assert node.len == 2, errWrongSql & "`from` " & node.lineInfo
        if isQuestionChar(node[1]):
          sqls.add "FROM ?" & n
        else:
          sqls.add "FROM " & $node[1] & n
      else: assert false, inner.lineInfo
    of nnkCall:
      case $node[0]
      of "select":
        assert node.len >= 2, errWrongSql & "select " & node.lineInfo
        if isQuestionChar(node[1]):
          sqls.add "SELECT ?" & n
        elif isAsteriskChar(node[1]):
          sqls.add "SELECT *" & n
        else:
          sqls.add "SELECT "
          sqls.add $node[1]
          sqls.add n
      of "where":
        assert node.len >= 2, errWrongSql & "where " & node.lineInfo
        if isQuestionChar(node[1]):
          sqls.add "WHERE ?" & n
        else:
          sqls.add "WHERE " & $node[1] & n
      else: assert false, inner.lineInfo
    else: assert false, inner.lineInfo
  sqls.add (when defined(release): ";" else: "; /* " & inner.lineInfo & " */\n")
  when defined(dev): echo sqls
  sqls = case $output
    of "tryExec": "tryExec(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "getRow": "getRow(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "getAllRows": "getAllRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "getValue": "getValue(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "tryInsertID": "tryInsertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "insertID": "insertID(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    of "execAffectedRows": "execAffectedRows(db, sql(\"\"\"" & sqls & "\"\"\"), args)"
    else: "sql(\"\"\"" & sqls & "\"\"\")"
  result = parseStmt sqls


when isMainModule:
  ############################### Compile-Time ################################
  const foo = query sql:
    select(foo, bar, baz)
    `from`things
    where("cost > 30", "foo > 9")
    offset 9
    limit 1
    order by desc
  echo foo.string

  const bar = query sql:
    select('*')
    `from`'?'
    where("cost > 30", "foo > 9")
    offset '?'
    limit '?'
    order by '?'
  echo bar.string

  const baz = query sql:
    select('?')
    `from`'?'
    where("cost > 30", "foo > 9")
    offset 9223372036854775807
    limit 9223372036854775807
    order by asc
  echo baz.string


  ################################## Run-Time #################################
  import db_sqlite  # `db: DbConn` and `args: varargs` must exist previously.
  let db = db_sqlite.open(":memory:", "", "", "")  # Just for demostrations.
  const args = ["args", "and", "db", "must", "be", "on", "pre-existing", "variables"]

  let runTimeTryQuery = query tryExec:
    select('?')
    `from`'?'
    where("cost > 30", "foo > 9")
    offset 9223372036854775807
    limit 9223372036854775807
    order by asc
  echo runTimeTryQuery

  let runTimeQuery = query tryInsertID:
    select('?')
    `from`'?'
    where("cost > 30", "foo > 9")
    offset 9223372036854775807
    limit 9223372036854775807
    order by asc
  echo runTimeQuery


  # Copied from https://github.com/Araq/ormin/blob/master/examples/forum/forum.nim
  # let threads = query sql:
  #   select(id, name, views, modified)
  #   `from` thread
  #   where id in (select post(thread) where author in
  #       (select person(id) where status notin ("Spammer") or id == ?id))
  #   order by desc(modified)
  #   limit 9
  #   offset 42

  let thisThread = query sql:
    select(id)
    `from` thread
    where("id == 42")
  echo thisThread.string

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
