## Gatabase Sugar
## ==============
##
## Syntax Sugar for Gatabase using `{.experimental: "dotOperators".}` and `template`,
## include or import *after* importing `db_sqlite` or `db_postgres` to use it on your code.
##
## .. code-block::nim
##   import db_sqlite
##   include gatabase/sugar
##
## .. code-block::nim
##   import db_postgres
##   include gatabase/sugar
##
## This templates are very efficient, no stdlib imports, no object heap alloc,
## no string formatting, just primitives, no more than 1 variable used.

import db_common, std/exitprocs
when defined(postgres): from db_postgres import Row else: from db_sqlite import Row

const
  dbInt* = "INTEGER NOT NULL DEFAULT 0"      ## Alias for Integer for SQLite and Postgres.
  dbString* = """TEXT NOT NULL DEFAULT ''""" ## Alias for String for SQLite and Postgres.
  dbFloat* = "REAL NOT NULL DEFAULT 0.0"     ## Alias for Float for SQLite and Postgres.
  dbBool* = "BOOLEAN NOT NULL DEFAULT false" ## Alias for Boolean for SQLite and Postgres.
  dbTimestamp* = "TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" ## Alias for Timestamp for SQLite and Postgres.


{.push experimental: "dotOperators".}
template `.`*(indx: int; data: Row): int = parseInt(data[indx])               ## `9.row` alias for `parseInt(row[9])`.
template `.`*(indx: char; data: Row): char = char(data[parseInt(indx)])       ## `'9'.row` alias for `char(row[9])`.
template `.`*(indx: uint; data: Row): uint = uint(parseInt(data[indx]))       ## `9'u.row` alias for `uint(parseInt(row[9]))`.
template `.`*(indx: cint; data: Row): cint = cint(parseInt(data[indx]))       ## `cint(9).row` alias for `cint(parseInt(row[9]))`.
template `.`*(indx: int8; data: Row): int8 = int8(parseInt(data[indx]))       ## `9'i8.row` alias for `int8(parseInt(row[9]))`.
template `.`*(indx: byte; data: Row): byte = byte(parseInt(data[indx]))       ## `byte(9).row` alias for `byte(parseInt(row[9]))`.
template `.`*(indx: int16; data: Row): int16 = int16(parseInt(data[indx]))    ## `9'i16.row` alias for `int16(parseInt(row[9]))`.
template `.`*(indx: int32; data: Row): int32 = int32(parseInt(data[indx]))    ## `9'i32.row` alias for `int32(parseInt(row[9]))`.
template `.`*(indx: int64; data: Row): int64 = int64(parseInt(data[indx]))    ## `9'i64.row` alias for `int64(parseInt(row[9]))`.
template `.`*(indx: uint8; data: Row): uint8 = uint8(parseInt(data[indx]))    ## `9'i64.row` alias for `uint8(parseInt(row[9]))`.
template `.`*(indx: uint16; data: Row): uint16 = uint16(parseInt(data[indx])) ## `9'i64.row` alias for `uint16(parseInt(row[9]))`.
template `.`*(indx: uint32; data: Row): uint32 = uint32(parseInt(data[indx])) ## `9'i64.row` alias for `uint32(parseInt(row[9]))`.
template `.`*(indx: uint64; data: Row): uint64 = uint64(parseInt(data[indx])) ## `9'i64.row` alias for `uint64(parseInt(row[9]))`.
template `.`*(indx: float; data: Row): float = parseFloat(data[int(indx)])              ## `9.0.row` alias for `parseFloat(row[9])`.
template `.`*(indx: Natural; data: Row): Natural = Natural(parseInt(data[indx]))             ## `Natural(9).row` alias for `Natural(parseInt(row[9]))`.
template `.`*(indx: cstring; data: Row): cstring = cstring(data[parseInt($indx)])            ## `cstring("9").row` alias for `cstring(row[9])`.
template `.`*(indx: Positive; data: Row): Positive = Positive(parseInt(data[indx]))          ## `Positive(9).row` alias for `Positive(parseInt(row[9]))`.
template `.`*(indx: BiggestInt; data: Row): BiggestInt = BiggestInt(parseInt(data[indx]))    ## `BiggestInt(9).row` alias for `BiggestInt(parseInt(row[9]))`.
template `.`*(indx: BiggestUInt; data: Row): BiggestUInt = BiggestUInt(parseInt(data[indx])) ## `BiggestUInt(9).row` alias for `BiggestUInt(parseInt(row[9]))`.
template `.`*(indx: float32; data: Row): float32 = float32(parseFloat(data[int(indx)])) ## `9.0'f32.row` alias for `float32(parseFloat(row[9]))`.
{.pop.}


template withSqlite*(path: static[string]; initTableSql: static[string]; closeOnQuit: static[bool]; closeOnCtrlC: static[bool]; code: untyped): untyped =
  ## Open, run `initTableSql` and Auto-Close a SQLite database.
  ## * `path` path to SQLite database file.
  ## * `initTableSql` SQL query string to initialize the database, `create table if not exists` alike.
  ## * `closeOnQuit` if `true` then `addQuitProc(db.close())` is set.
  ## * `closeOnCtrlC` if `true` then `setControlCHook(db.close())` is set.
  ##
  ## .. code-block::nim
  ##   import db_sqlite
  ##   include gatabase/sugar
  ##   const exampleTable = """
  ##     create table if not exists person(
  ##       id      integer primary key,
  ##       name    text,
  ##       active  bool,
  ##       rank    float
  ##   ); """
  ##
  ##   withSqlite(":memory:", exampleTable, false):  ## This is just an example.
  ##     db.exec(sql"insert into person(name, active, rank) values('pepe', true, 42.0)")
  assert path.len > 0, "path must not be empty string"
  var db {.inject, global.} = db_sqlite.open(path, "", "", "")
  if initTableSql.len == 0 or db.tryExec(sql(initTableSql)):
    try:
      when closeOnQuit:  addExitProc((proc () {.noconv.} = db_sqlite.close(db)))
      when closeOnCtrlC: system.setControlCHook((proc () {.noconv.} = db_sqlite.close(db)))
      code
    finally:
      db_sqlite.close(db)
  else:
    when not defined(release): echo "Error executing initTableSql:\n" & initTableSql


template withPostgres*(host, user, password, dbname: string; initTableSql: static[string]; closeOnQuit: static[bool]; closeOnCtrlC: static[bool]; code: untyped): untyped =
  ## Open, run `initTableSql` and Auto-Close a Postgres database. See `withSqlite` for an example.
  ## * `host` host of Postgres Server, string type, must not be empty string.
  ## * `user` user of Postgres Server, string type, must not be empty string.
  ## * `password` password of Postgres Server, string type, must not be empty string.
  ## * `dbname` database name of Postgres Server, string type, must not be empty string.
  ## * `initTableSql` SQL query string to initialize the database, `create table if not exists` alike.
  ## * `closeOnQuit` if `true` then `addQuitProc(db.close())` is set.
  ## * `closeOnCtrlC` if `true` then `setControlCHook(db.close())` is set.
  assert host.len > 0, "host must not be empty string"
  assert user.len > 0, "user must not be empty string"
  assert password.len > 0, "password must not be empty string"
  assert dbname.len > 0, "dbname must not be empty string"
  var db {.inject, global.} = db_postgres.open(host, user, password, dbname)
  if initTableSql.len == 0 or db.tryExec(sql(initTableSql)):
    try:
      when closeOnQuit:  addExitProc((proc () {.noconv.} = db_postgres.close(db)))
      when closeOnCtrlC: system.setControlCHook((proc () {.noconv.} = db_postgres.close(db)))
      code
    finally:
      db_postgres.close(db)
  else:
    when not defined(release): echo "Error executing initTableSql:\n" & initTableSql


template dropTable*(db; name: string): bool =
  ## Alias for `tryExec(db, sql("DROP TABLE IF EXISTS ?"), name)`.
  ## Requires a `db` of `DbConn` type. Works with Postgres and Sqlite.
  ## Deleted tables can not be restored, be careful.
  assert name.len > 0, "Table name must not be empty string"
  tryExec(db, sql("DROP TABLE IF EXISTS ?" & (when defined(postgres): " CASCADE" else: "")), name)


template createTable*(name: static string; code: untyped): SqlQuery =
  ## Create a new database table `name` with fields from `code`, returns 1 `SqlQuery`.
  ## Works with Postgres and Sqlite. `SqlQuery` is pretty-printed when not built for release.
  ##
  ## .. code-block::nim
  ##   import db_sqlite
  ##   include gatabase/sugar
  ##   let myTable = createTable "kitten": [
  ##     "age"  := 1,
  ##     "sex"  := 'f',
  ##     "name" := "fluffy",
  ##     "rank" := 3.14,
  ##   ]
  ##
  ## Generates the SQL Query:
  ##
  ## .. code-block::
  ##   CREATE TABLE IF NOT EXISTS kitten(
  ##     id    INTEGER     PRIMARY KEY,
  ##     age   INTEGER     NOT NULL  DEFAULT 1,
  ##     sex   VARCHAR(1)  NOT NULL  DEFAULT 'f',
  ##     name  TEXT        NOT NULL  DEFAULT 'fluffy',
  ##     rank  REAL        NOT NULL  DEFAULT 3.14,
  ##   );
  ##
  assert name.len > 0, "Table name must not be empty string"
  assert code.len > 0, "Table fields must not be empty array"
  const nl = when defined(release): " " else: "\n"

  template `:=`(dbfield: static string; value: static any): string =
    # Template to create individual database fields with default values.
    assert dbfield.len > 0, "Table field name must not be empty string"
    (when defined(release): "" else: "  ") & dbfield & "\t" & (
      if value is char:          "VARCHAR(1)\tNOT NULL\tDEFAULT '" & $value & "'," & nl
      elif value is SomeFloat:   "REAL\tNOT NULL\tDEFAULT "  & $value & "," & nl
      elif value is SomeInteger: "INTEGER\tNOT NULL\tDEFAULT "  & $value & "," & nl
      elif value is bool:        "BOOLEAN\tNOT NULL\tDEFAULT "  & (if $value == "true": "1" else: "0") & "," & nl
      else:                      "TEXT\tNOT NULL\tDEFAULT '" & $value & "'," & nl)

  var cueri = "CREATE TABLE IF NOT EXISTS " & name & "(" & nl & (
    when defined(postgres): "  id\tINTEGER\tGENERATED BY DEFAULT AS IDENTITY,"
    else: "  id\tINTEGER\tPRIMARY KEY,") & nl
  for field in code: cueri.add field
  cueri.add ");" # http://blog.2ndquadrant.com/postgresql-10-identity-columns
  sql(cueri)
