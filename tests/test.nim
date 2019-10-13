## Gatabase Unittests.
import unittest, db_sqlite, ../src/gatabase  # Import LOCAL Gatabase


const exampleTable = sql"""
  create table if not exists person(
    id      integer      primary key,
    name    varchar(99)  not null unique,
    active  bool         not null default true,
    email   text         not null,
    rank    float        not null default 0.0
  ); """


suite "Gatabase ORM Tests":

  let db = db_sqlite.open(":memory:", "", "", "") # Setup.
  doAssert db.tryExec(exampleTable), "Error creating 'exampleTable'"


  test "let   INSERT INTO":
    query Exec:
      insertinto "person"
      values (42, "Graydon Hoare", true, "graydon.hoare@nim-lang.org", 5.5)


  test "let   SELECT ... FROM ... WHERE":
    query Exec:
      select '*'
      `from` "person"
      where  "id = 42"


  test "let   SELECT ... (comment) ... FROM ... COMMENT":
    query Exec:
      select '*'
      `--`   "This is a comment, this will be strapped for Release builds"
      `from` "person"
      commentontable {"person": "This is an SQL COMMENT on a TABLE"}


  test "let   SELECT ... FROM ... LIMIT ... OFFSET":
    query Exec:
      select '*'
      `from` "person"
      limit  2
      offset 0


  test "let   INSERT INTO":
    query Exec:
      insertinto "person"
      values (99, "Ryan Dahl", false, "ryan.dahl@nim-lang.org", 9.6)


  test "let   UNION ALL ... ORBER BY ... IS NOT NULL":
    query Exec:
      select '*'
      `from` "person"
      where  "id = 42"
      union  true
      select '*'
      `from` "person"
      where  "name"
      isnull false


  test "let   SELECT DISTINCT ... FROM ... WHERE":
    query Exec:
      selectdistinct "id"
      `from`"person"
      where "rank != 666.0"


  test "let INSERT INTO":
    query Exec:
      insertinto "person"
      values (9, "Guido van Rossum", true, "guido.v.rossum@nim-lang.org", 5.5)


  test "const SELECT ... FROM ... WHERE":
    const example9 {.used.} = query Sql:
      select '*'
      `from` "person"
      where  "id = 42"


  test "const SELECT ... (comment) ... FROM ... COMMENT":
    const example10 {.used.} = query Prepared:
      select '*'
      `--`   "This is a comment, this will be strapped for Release builds"
      `from` "person"
      commentontable {"person": "This is an SQL COMMENT on a TABLE"}


  test "const SELECT ... FROM ... LIMIT ... OFFSET":
    const example11 {.used.} = query Func:
      select '*'
      `from` "person"
      limit  2
      offset 0


  test "const INSERT INTO":
    const example12 {.used.} = query Sql:
      insertinto "person"
      values (99, "Rob Pike", false, "rob.pike@nim-lang.org", 9.6)


  test "const UNION ALL ... ORBER BY ... IS NOT NULL":
    const example13 {.used.} = query Prepared:
      select  '*'
      `from`  "person"
      where   "id = 42"
      union   true
      select  '*'
      `from`  "person"
      where   "name"
      isnull  false
      orderby Asc


  test "const INTERSECT ALL":
    const example13a {.used.} = query Sql:
      select '*'
      `from` "person"
      intersect true
      select '*'
      `from` "person"


  test "const EXCEPT ALL":
    const example13b {.used.} = query Sql:
      select '*'
      `from` "person"
      `except` true
      select '*'
      `from` "person"


  test "const SELECT DISTINCT ... FROM ... WHERE":
    const example14 {.used.} = query Sql:
      selectdistinct "id"
      `from` "person"
      where  "rank != 666.0"


  test "var   CASE":
    var example15 {.used.} = query Sql:
      `case` {"foo > 10": "9", "bar < 42": "5", "else":  "0"}
      `case` {
        "foo > 10": "9",
        "bar < 42": "5",
        "else":  "0"
      }


  test "var   SELECT MAX .. WHERE EXISTS ... OFFSET ... LIMIT ... ORDER BY":
    var foo {.used.} = query TryExec:
      selectmax '*'
      `--`    "This is a comment."
      `from`  "person"
      `--`    "This is a comment."
      whereexists "rank > 0.0"
      `--`    "This is a comment."
      `--`    "This is a comment."
      limit   1
      offset  0
      `--`    "This is a comment."
      orderby Desc


  test "SELECT TRIM":
    query Exec:
      selecttrim "name"
      `from` "person"


  test "SELECT ROUND":
    query Exec:
      selectround2 "rank"
      `from` "person"

    query Exec:
      selectround4 "rank"
      `from` "person"

    query Exec:
      selectround6 "rank"
      `from` "person"


  test "var   DELETE FROM WHERE":
    query Exec:
      delete "person"

  close db # TearDown.
