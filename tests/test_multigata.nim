## Gatabase Unittests.
import unittest, asyncdispatch, db_common, ../src/gatabase  # Import LOCAL Gatabase


let db = newGatabase("localhost", "postgres", "postgres", "postgres", unroll = 9)
doAssert db is Gatabase
let data = wait_for getAllRows(db, query = sql"SELECT version();", @[])
doAssert data is seq[Row]
doAssert len(data) > 0 and len(data[0]) > 0
echo data[0]  # Postgres 12
doAssert execAffectedRows(db, query = sql"SELECT version();", @[]) is Future[int64]
doAssert exec(db, query = sql"SELECT version();", @[]) is Future[void]
for _ in 0 .. len(db) - 1: doAssert db.getAllRows(sql"SELECT version();", @[]) is Future[seq[Row]]


var args: seq[string] # Just for testing, can also be @[]

let dataset0: Future[seq[Row]] = args.getAllRows:
  select "version()"

let dataset1: Future[int64] = args.execAffectedRows:
  select "version()"

# asyncCheck exec args:
#   select "version()"
#   `--`   "You can await() them too, this is just an example."


echo $db
db.close(unroll = 9)
