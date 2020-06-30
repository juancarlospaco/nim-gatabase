## Gatabase Unittests.
import unittest, asyncdispatch, db_common, ../src/gatabase  # Import LOCAL Gatabase


const exampleTable = sql"""
  create table if not exists person(
    id      integer      primary key,
    name    varchar(99)  not null unique,
    active  bool         not null default true,
    email   text         not null,
    rank    float        not null default 0.0
  ); """


# Manual
let db = newGatabase("localhost", "postgres", "postgres", "postgres")
doAssert db is Gatabase
doAssert len(db) == 100
let data = wait_for getAllRows(db, query = sql"SELECT version();", @[])
doAssert data is seq[Row]
doAssert len(data) > 0 and len(data[0]) > 0
echo data[0]
doAssert execAffectedRows(db, query = sql"SELECT version();", @[]) is Future[int64]
doAssert exec(db, query = sql"SELECT version();", @[]) is Future[void]
for _ in 0 .. len(db) - 1: doAssert db.getAllRows(sql"SELECT version();", @[]) is Future[seq[Row]]


# DSL
let dataset0: Future[seq[Row]] = @[].getAllRows:
  select "version()"

let dataset1: Future[int64] = @[].execAffectedRows:
  select "version()"

let dataset2: Future[void] = @[].exec:
  select "version()"


echo $db
db.close()
