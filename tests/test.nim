import unittest, db_sqlite
import ../src/gatabase


const exampleTable = sql"""
    create table if not exists person(
      id      integer     primary key,
      name    varchar(9)  not null unique,
      active  bool        not null default true,
      email   text        not null,
      rank    float       not null default 0.0
    ); """


suite "Gatabase ORM Tests":

  let db = db_sqlite.open(":memory:", "", "", "") # Setup.
  doAssert db.tryExec(exampleTable), "Error creating 'exampleTable'"


  test "let   INSERT INTO":
    let example {.used.} = query TryExec:
      insertinto "person"
      values (42, "maximus", true, "maximus.nimmer@nim-lang.org", 5.5)


  test "let   SELECT ... FROM ... WHERE":
    let example2 {.used.} = query TryExec:
      select '*'
      `from`"person"
      where "id = 42"


  test "let   SELECT ... (comment) ... FROM ... COMMENT":
    let example2 {.used.} = query TryExec:
      select '*'
      `--`"This is a comment, this will be strapped for Release builds"
      `from`"person"
      comment {"on": "TABLE", "person": "This is an SQL COMMENT on a TABLE"}


  test "let   SELECT ... FROM ... LIMIT ... OFFSET":
    let example2 {.used.} = query TryExec:
      select '*'
      `from`"person"
      offset 0
      limit 2


  test "let   INSERT INTO":
    let example3 {.used.} = query Func:
      insertinto "person"
      values (99, "Nikola Tesla", false, "nikola.tesla@nim-lang.org", 9.6)


  test "let   UNION ALL ... ORBER BY ... IS NOT NULL":
    let example2 {.used.} = query Sql:
      select '*'
      `from`"person"
      where "id = 42"
      union true
      select '*'
      `from`"person"
      where "name"
      isnull false
      orderby "asc"


  test "let   SELECT DISTINCT ... FROM ... WHERE":
    let example2 {.used.} = query Prepared:
      selectdistinct "id"
      `from`"person"
      where "rank != 666.0"


  test "const INSERT INTO":
    const example {.used.} = query Func:
      insertinto "person"
      values (42, "maximus", true, "maximus.nimmer@nim-lang.org", 5.5)


  test "const SELECT ... FROM ... WHERE":
    const example2 {.used.} = query Sql:
      select '*'
      `from`"person"
      where "id = 42"


  test "const SELECT ... (comment) ... FROM ... COMMENT":
    const example2 {.used.} = query Prepared:
      select '*'
      `--`"This is a comment, this will be strapped for Release builds"
      `from`"person"
      comment {"on": "TABLE", "person": "This is an SQL COMMENT on a TABLE"}


  test "const SELECT ... FROM ... LIMIT ... OFFSET":
    const example2 {.used.} = query Func:
      select '*'
      `from`"person"
      offset 0
      limit 2


  test "const INSERT INTO":
    const example3 {.used.} = query Sql:
      insertinto "person"
      values (99, "Nikola Tesla", false, "nikola.tesla@nim-lang.org", 9.6)


  test "const UNION ALL ... ORBER BY ... IS NOT NULL":
    const example2 {.used.} = query Prepared:
      select '*'
      `from`"person"
      where "id = 42"
      union true
      select '*'
      `from`"person"
      where "name"
      isnull false
      orderby "asc"


  test "const SELECT DISTINCT ... FROM ... WHERE":
    const example2 {.used.} = query Sql:
      selectdistinct "id"
      `from`"person"
      where "rank != 666.0"


  test "var   CASE":
    var example2 {.used.} = query Sql:
      `case` {"foo > 10": "9", "bar < 42": "5", "default": "0"}


  test "var   SELECT MAX .. WHERE EXISTS ... OFFSET ... LIMIT ... ORDER BY":
    var foo {.used.} = query TryExec:
      selectmax '*'
      `--`"This is a comment."
      `from`"person"
      `--`"This is a comment."
      whereexists "rank > 0.0"
      `--`"This is a comment."
      offset 0
      `--`"This is a comment."
      limit 1
      `--`"This is a comment."
      orderby "desc"


  test "var   DELETE FROM WHERE":
    var example9 {.used.} = query TryExec:
      delete "person"
      where "id = 42"

  close db # TearDown.
