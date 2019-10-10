import unittest, db_sqlite
import ../src/gatabase


const exampleTable = sql"""

    create table if not exists person(
      id      integer     primary key,
      name    varchar(9)  not null unique,
      active  bool        not null default true,
      email   text        not null,
      rank    float       not null default 0.0
    );

  """


suite "Gatabase ORM Tests":

  let db = db_sqlite.open(":memory:", "", "", "")  # Setup.
  doAssert db.tryExec(exampleTable), "Error creating 'exampleTable'"


  test "INSERT INTO":
    let example {.used.} = query TryExec:
      insertinto "person"
      values (42, "maximus", true, "maximus.nimmer@nim-lang.org", 5.5)


  test "SELECT ... FROM ... WHERE":
    let example2 {.used.} = query TryExec:
      select '*'
      `from` "person"
      where "id = 42"


  test "SELECT ... (comment) ... FROM ... COMMENT":
    let example2 {.used.} = query TryExec:
      select '*'
      `--` "This is a comment, this will be strapped for Release builds"
      `from` "person"
      comment {"on": "TABLE", "person": "This is an SQL COMMENT on a TABLE"}


  test "SELECT ... FROM ... LIMIT ... OFFSET":
    let example2 {.used.} = query TryExec:
      select '*'
      `from` "person"
      offset 0
      limit 2


  test "INSERT INTO":
    let example3 {.used.} = query TryExec:
      insertinto "person"
      values (99, "Nikola Tesla", false, "nikola.tesla@nim-lang.org", 9.6)


  test "UNION ... ORBER BY":
    let example2 {.used.} = query TryExec:
      select '*'
      `from` "person"
      where "id = 42"
      union true
      select '*'
      `from` "person"
      where "id = 99"
      orderby "asc"


  test "DELETE FROM WHERE":
    let example9 {.used.} = query TryExec:
      delete "person"
      where "id = 42"

  close db  # TearDown.
