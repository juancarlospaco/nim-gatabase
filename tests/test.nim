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


const expected0 = """INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
;  /* /home/juan/code/nim-gatabase/tests/test.nim(82, 6) */
"""

const expected1 = """SELECT *
FROM person
WHERE id = 42
;  /* /home/juan/code/nim-gatabase/tests/test.nim(89, 6) */
"""

const expected2 = """SELECT *
-- This is a comment, this will be strapped for Release builds
FROM person

;  /* /home/juan/code/nim-gatabase/tests/test.nim(97, 6) */
"""

const expected3 = """SELECT *
FROM person
LIMIT 2
OFFSET 0
;  /* /home/juan/code/nim-gatabase/tests/test.nim(106, 6) */
"""

const expected4 = """INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
;  /* /home/juan/code/nim-gatabase/tests/test.nim(115, 6) */
"""

const expected5 = """SELECT *
FROM person
WHERE id = 42
UNION ALL
SELECT *
FROM person
WHERE name
IS NOT NULL
;  /* /home/juan/code/nim-gatabase/tests/test.nim(122, 6) */
"""

const expected6 = """SELECT DISTINCT id
FROM person
WHERE rank != 666.0
;  /* /home/juan/code/nim-gatabase/tests/test.nim(135, 6) */
"""

const expected7 = """INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
;  /* /home/juan/code/nim-gatabase/tests/test.nim(143, 6) */
"""

const expected8 = """SELECT *
FROM person
WHERE id = 42
;  /* /home/juan/code/nim-gatabase/tests/test.nim(150, 6) */
"""


suite "Gatabase ORM Tests":

  let db = db_sqlite.open(":memory:", "", "", "") # Setup.
  doAssert db.tryExec(exampleTable), "Error creating 'exampleTable'"


  test "let   INSERT INTO":
    let result0 = query Sql:
      insertinto "person"
      values (42, "Graydon Hoare", true, "graydon.hoare@nim-lang.org", 5.5)
    check result0.string == expected0


  test "let   SELECT ... FROM ... WHERE":
    let result1 = query Sql:
      select '*'
      `from` "person"
      where  "id = 42"
    check result1.string == expected1


  test "let   SELECT ... (comment) ... FROM ... COMMENT":
    let result2 = query Sql:
      select '*'
      `--`   "This is a comment, this will be strapped for Release builds"
      `from` "person"
      commentontable {"person": "This is an SQL COMMENT on a TABLE"}
    check result2.string == expected2


  test "let   SELECT ... FROM ... LIMIT ... OFFSET":
    let result3 = query Sql:
      select '*'
      `from` "person"
      limit  2
      offset 0
    check result3.string == expected3


  test "let   INSERT INTO":
    let result4 = query Sql:
      insertinto "person"
      values (99, "Ryan Dahl", false, "ryan.dahl@nim-lang.org", 9.6)
    check result4.string == expected4


  test "let   UNION ALL ... ORBER BY ... IS NOT NULL":
    let result5 = query Sql:
      select '*'
      `from` "person"
      where  "id = 42"
      union  true
      select '*'
      `from` "person"
      where  "name"
      isnull false
    check result5.string == expected5


  test "let   SELECT DISTINCT ... FROM ... WHERE":
    let result6 = query Sql:
      selectdistinct "id"
      `from`"person"
      where "rank != 666.0"
    check result6.string == expected6


  test "let INSERT INTO":
    let result7 = query Sql:
      insertinto "person"
      values (9, "Guido van Rossum", true, "guido.v.rossum@nim-lang.org", 5.5)
    check result7.string == expected7


  # test "const SELECT ... FROM ... WHERE":
  #   const result8 = query Sql:
  #     select '*'
  #     `from` "person"
  #     where  "id = 42"
  #   check result8.string == expected8


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
