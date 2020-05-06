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
{.experimental: "dotOperators".}

const
  dbInt* = "INTEGER NOT NULL DEFAULT 0"      ## Alias for Integer for SQLite and Postgres.
  dbString* = """TEXT NOT NULL DEFAULT ''""" ## Alias for String for SQLite and Postgres.
  dbFloat* = "REAL NOT NULL DEFAULT 0.0"     ## Alias for Float for SQLite and Postgres.
  dbBool* = "BOOLEAN NOT NULL DEFAULT false" ## Alias for Boolean for SQLite and Postgres.
  dbTimestamp* = "TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" ## Alias for Timestamp for SQLite and Postgres.

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
template `.`*(indx: float; data: Row): float = parseFloat(data[parseInt(indx)])              ## `9.0.row` alias for `parseFloat(row[9])`.
template `.`*(indx: Natural; data: Row): Natural = Natural(parseInt(data[indx]))             ## `Natural(9).row` alias for `Natural(parseInt(row[9]))`.
template `.`*(indx: cstring; data: Row): cstring = cstring(data[parseInt($indx)])            ## `cstring("9").row` alias for `cstring(row[9])`.
template `.`*(indx: Positive; data: Row): Positive = Positive(parseInt(data[indx]))          ## `Positive(9).row` alias for `Positive(parseInt(row[9]))`.
template `.`*(indx: BiggestInt; data: Row): BiggestInt = BiggestInt(parseInt(data[indx]))    ## `BiggestInt(9).row` alias for `BiggestInt(parseInt(row[9]))`.
template `.`*(indx: BiggestUInt; data: Row): BiggestUInt = BiggestUInt(parseInt(data[indx])) ## `BiggestUInt(9).row` alias for `BiggestUInt(parseInt(row[9]))`.
template `.`*(indx: float32; data: Row): float32 = float32(parseFloat(data[parseInt(indx)])) ## `9.0'f32.row` alias for `float32(parseFloat(row[9]))`.

template withSqlite*(path: static[string]; initTableSql: static[string]; closeOnQuit: static[bool]; code: untyped): untyped =
  ## Open, run `initTableSql` and Auto-Close a SQLite database.
  ## * `path` path to SQLite database file.
  ## * `initTableSql` SQL query string to initialize the database, `create table if not exists` alike.
  ## * `closeOnQuit` if `true` then `addQuitProc(db.close()); code` is used, if `false` then `try: code finally: db.close()` is used.
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
  let db {.inject, global.} = db_sqlite.open(path, "", "", "")
  if initTableSql.len == 0 or db.tryExec(sql(initTableSql)):
    when closeOnQuit:
      system.addQuitProc((proc () {.noconv.} = db.close()))
      code
    else:
      try:
        code
      finally:
        db.close()
  else:
    when not defined(release): echo "Error executing initTableSql:\n" & initTableSql

template withPostgres*(host, user, password, dbname: string; initTableSql: static[string]; closeOnQuit: static[bool]; code: untyped): untyped =
  ## Open, run `initTableSql` and Auto-Close a Postgres database. See `withSqlite` for an example.
  ## * `host` host of Postgres Server, string type, must not be empty string.
  ## * `user` user of Postgres Server, string type, must not be empty string.
  ## * `password` password of Postgres Server, string type, must not be empty string.
  ## * `dbname` database name of Postgres Server, string type, must not be empty string.
  ## * `initTableSql` SQL query string to initialize the database, `create table if not exists` alike.
  ## * `closeOnQuit` if `true` then `addQuitProc(db.close()); code` is used, if `false` then `try: code finally: db.close()` is used.
  assert host.len > 0, "host must not be empty string"
  assert user.len > 0, "user must not be empty string"
  assert password.len > 0, "password must not be empty string"
  assert dbname.len > 0, "dbname must not be empty string"
  let db {.inject, global.} = db_postgres.open(host, user, password, dbname)
  if initTableSql.len == 0 or db.tryExec(sql(initTableSql)):
    when closeOnQuit:
      system.addQuitProc((proc () {.noconv.} = db.close()))
      code
    else:
      try:
        code
      finally:
        db.close()
  else:
    when not defined(release): echo "Error executing initTableSql:\n" & initTableSql
