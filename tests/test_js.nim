## Gatabase Unittests.
import unittest, db_common, ../src/gatabase  # Import LOCAL Gatabase


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
;
"""

const expected1 = """SELECT *
FROM person
WHERE id = 42
;
"""

const expected2 = """SELECT *
/* This is a comment, this will be strapped for Release builds */
FROM person

;
"""

const expected3 = """SELECT *
FROM person
LIMIT 2
OFFSET 0
;
"""

const expected4 = """INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
;
"""

const expected5 = """SELECT *
FROM person
WHERE id = 42
UNION ALL
SELECT *
FROM person
WHERE name
IS NOT NULL
;
"""

const expected6 = """SELECT DISTINCT id
FROM person
WHERE rank != 666.0
;
"""

const expected7 = """INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
;
"""

const expected8 = """SELECT *
FROM person
WHERE id = 42
;
"""


suite "Gatabase ORM Tests":

  test "let   INSERT INTO":
    let result0 = sqls:
      insertinto "person"
      values     5
    check result0.string == expected0


  test "let   SELECT ... FROM ... WHERE":
    let result1 = sqls:
      select '*'
      `from` "person"
      where  "id = 42"
    check result1.string == expected1


  test "let   SELECT ... (comment) ... FROM ... COMMENT":
    let result2 = sqls:
      select '*'
      `--`   "This is a comment, this will be strapped for Release builds"
      `from` "person"
      commentontable {"person": "This is an SQL COMMENT on a TABLE"}
    check result2.string == expected2


  test "let   SELECT ... FROM ... LIMIT ... OFFSET":
    let result3 = sqls:
      select '*'
      `from` "person"
      limit  2
      offset 0
    check result3.string == expected3


  test "let   INSERT INTO":
    let result4 = sqls:
      insertinto "person"
      values     5
    check result4.string == expected4


  test "let   UNION ALL ... ORBER BY ... IS NOT NULL":
    let result5 = sqls:
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
    let result6 = sqls:
      selectdistinct "id"
      `from`"person"
      where "rank != 666.0"
    check result6.string == expected6


  test "let INSERT INTO":
    let result7 = sqls:
      insertinto "person"
      values     5
    check result7.string == expected7


  test "const SELECT ... (comment) ... FROM ... COMMENT":
    const example10 {.used.} = sqls:
      select '*'
      `--`   "This is a comment, this will be strapped for Release builds"
      `from` "person"
      commentontable {"person": "This is an SQL COMMENT on a TABLE"}


  test "const SELECT ... FROM ... LIMIT ... OFFSET":
    const example11 {.used.} = sqls:
      select '*'
      `from` "person"
      limit  2
      offset 0


  test "const INSERT INTO":
    const example12 {.used.} = sqls:
      insertinto "person"
      values     5


  test "const UNION ALL ... ORBER BY ... IS NOT NULL":
    const example13 {.used.} = sqls:
      select  '*'
      `from`  "person"
      where   "id = 42"
      union   true
      select  '*'
      `from`  "person"
      where   "name"
      isnull  false
      orderby "id"


  test "const INTERSECT ALL":
    const example13a {.used.} = sqls:
      select '*'
      `from` "person"
      intersect true
      select '*'
      `from` "person"


  test "const EXCEPT ALL":
    const example13b {.used.} = sqls:
      select '*'
      `from` "person"
      `except` true
      select '*'
      `from` "person"


  test "const SELECT DISTINCT ... FROM ... WHERE":
    const example14 {.used.} = sqls:
      selectdistinct "id"
      `from` "person"
      where  "rank != 666.0"


  test "var   CASE":
    var example15 {.used.} = sqls:
      `case` {"foo > 10": "9", "bar < 42": "5", "else":  "0"}
      `case` {
        "foo > 10": "9",
        "bar < 42": "5",
        "else":  "0"
      }
