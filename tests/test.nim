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


suite "Gatabase Compile-Time ORM Tests":

  let db {.global, used.} = db_sqlite.open(":memory:", "", "", "")

  setup:
    doAssert db.tryExec(exampleTable), "Could not Create 'exampleTable'"

  teardown:
    doAssert db.tryExec(sql"DELETE FROM person"), "Could not Delete 'exampleTable'"


  test "INSERT INTO":
    let example {.used.} = query TryExec:
      insertinto "person"
      values (42, "maximus", true, "maximus.nimmer@nim-lang.org", 5.5)


  test "SELECT FROM WHERE":
    let example2 {.used.} = query TryExec:
      select '*'
      `from` "person"
      where "id = 42"


  test "INSET INTO":
    let example3 {.used.} = query TryExec:
      insertinto "person"
      values (42, "Nikola Tesla", false, "nikola.tesla@nim-lang.org", 9.6)


  test "DELETE FROM WHERE":
    let example9 {.used.} = query TryExec:
      delete "person"
      where "id = 42"


  db.close  # TearDown.
