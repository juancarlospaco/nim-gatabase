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

let multigata = newGatabase("localhost", "postgres", "postgres", "postgres")
doAssert multigata is Gatabase
doAssert len(multigata) == 100
let data = await getAllRows(multigata, query = sql"SELECT version();", @[])
doAssert data is seq[Row]
doAssert len(data) > 0 and len(data[0]) > 0
doAssert execAffectedRows(multigata, query = sql"SELECT version();", @[]) is Future[int64]
doAssert exec(multigata, query = sql"SELECT version();", @[]) is Future[void]
for _ in 0 .. len(multigata) - 1: doAssert multigata.getAllRows(sql"SELECT version();", @[]) is Future[seq[Row]]
echo $multigata
multigata.close()
