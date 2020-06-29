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

var multigata = newGatabase("localhost", "postgres", "postgres", "postgres")
doAssert len(multigata) == 100

var test0 = getAllRows(multigata, query = sql"SELECT version();", @[])
echo type(test0)
