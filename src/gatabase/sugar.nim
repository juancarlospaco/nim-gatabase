## Gatabase Sugar
## ==============
##
## .. image:: https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/docs/sugar.jpg
##
## Syntax Sugar for Gatabase using `template`.
##
## `include` or `import` *after* importing `db_sqlite` or `db_postgres` to use it on your code.
##
## .. code-block::nim
##   import db_sqlite
##   include gatabase/sugar
##
## .. code-block::nim
##   import db_postgres
##   include gatabase/sugar
##
## All Gatabase sugar is always optional.
## The templates are very efficient, no stdlib imports, no object heap alloc,
## no string formatting, just primitives, no more than 1 variable used.

import db_common, std/exitprocs
when defined(postgres): from db_postgres import Row else: from db_sqlite import Row

{.push experimental: "dotOperators".}
template `.`*(indx: int; data: Row): int = parseInt(data[indx])
  ## `9.row` convenience alias for `strutils.parseInt(row[9])` (`row` is `Row` type).
template `.`*(indx: char; data: Row): char = char(data[parseInt($indx)][0])
  ## `'9'.row` convenience alias for `char(row[strutils.parseInt($indx)][0])` (`row` is `Row` type).
template `.`*(indx: uint; data: Row): uint = uint(parseInt(data[indx]))
  ## `9'u.row` convenience alias for `uint(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: cint; data: Row): cint = cint(parseInt(data[indx]))
  ## `cint(9).row` convenience alias for `cint(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: int8; data: Row): int8 = int8(parseInt(data[indx]))
  ## `9'i8.row` convenience alias for `int8(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: byte; data: Row): byte = byte(parseInt(data[indx]))
  ## `byte(9).row` convenience alias for `byte(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: int16; data: Row): int16 = int16(parseInt(data[indx]))
  ## `9'i16.row` convenience alias for `int16(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: int32; data: Row): int32 = int32(parseInt(data[indx]))
  ## `9'i32.row` convenience alias for `int32(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: int64; data: Row): int64 = int64(parseInt(data[indx]))
  ## `9'i64.row` convenience alias for `int64(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: uint8; data: Row): uint8 = uint8(parseInt(data[indx]))
  ## `9'u8.row` convenience alias for `uint8(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: uint16; data: Row): uint16 = uint16(parseInt(data[indx]))
  ## `9'u16.row` convenience alias for `uint16(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: uint32; data: Row): uint32 = uint32(parseInt(data[indx]))
  ## `9'u32.row` convenience alias for `uint32(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: uint64; data: Row): uint64 = uint64(parseInt(data[indx]))
  ## `9'u64.row` convenience alias for `uint64(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: float; data: Row): float = parseFloat(data[int(indx)])
  ## `9.0.row` convenience alias for `strutils.parseFloat(row[int(9)])` (`row` is `Row` type).
template `.`*(indx: Natural; data: Row): Natural = Natural(parseInt(data[indx]))
  ## `Natural(9).row` convenience alias for `Natural(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: cstring; data: Row): cstring = cstring(data[parseInt($indx)])
  ## `cstring("9").row` convenience alias for `cstring(row[9])` (`row` is `Row` type).
template `.`*(indx: Positive; data: Row): Positive = Positive(parseInt(data[indx]))
  ## `Positive(9).row` convenience alias for `Positive(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: BiggestInt; data: Row): BiggestInt = BiggestInt(parseInt(data[indx]))
  ## `BiggestInt(9).row` convenience alias for `BiggestInt(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: BiggestUInt; data: Row): BiggestUInt = BiggestUInt(parseInt(data[indx]))
  ## `BiggestUInt(9).row` convenience alias for `BiggestUInt(strutils.parseInt(row[9]))` (`row` is `Row` type).
template `.`*(indx: float32; data: Row): float32 = float32(parseFloat(data[int(indx)]))
  ## `9.0'f32.row` convenience alias for `float32(strutils.parseFloat(row[int(9)]))` (`row` is `Row` type).
{.pop.}


template createTable*(name: static string; code: untyped): SqlQuery =
  ## Create a new database table `name` with fields from `code`, returns 1 `SqlQuery`.
  ## Works with Postgres and Sqlite. `SqlQuery` is pretty-printed when not built for release.
  ##
  ## .. code-block::nim
  ##   import db_sqlite
  ##   include gatabase/sugar
  ##   let myTable = createTable "kitten": [
  ##     "age"    := 1,
  ##     "sex"    := 'f',
  ##     "name"   := "unnamed",
  ##     "rank"   := 3.14,
  ##     "weight" := int,
  ##     "color"  := char,
  ##     "owner"  := string,
  ##     "food"   := float,
  ##   ]
  ##
  ## Generates the SQL Query:
  ##
  ## .. code-block::
  ##   CREATE TABLE IF NOT EXISTS kitten(
  ##     id      INTEGER      PRIMARY KEY,
  ##     age     INTEGER      NOT NULL      DEFAULT 1,
  ##     sex     VARCHAR(1)   NOT NULL      DEFAULT 'f',
  ##     name    TEXT         NOT NULL      DEFAULT 'unnamed',
  ##     rank    REAL         NOT NULL      DEFAULT 3.14,
  ##     weight  INTEGER,
  ##     color   VARCHAR(1),
  ##     owner   TEXT,
  ##     food    REAL,
  ##   );
  ##
  ## More examples:
  ## * https://github.com/juancarlospaco/nim-gatabase/blob/master/examples/database_fields_example.nim#L1
  assert name.len > 0, "Table name must not be empty string"
  const nl = when defined(release): " " else: "\n"

  template `:=`(dbfield: static string; value: static char): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & dbfield & "\t" & "VARCHAR(1)\tNOT NULL\tDEFAULT '" & $value & "'," & nl

  template `:=`(dbfield: static string; value: static SomeFloat): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & dbfield & "\t" & "REAL\tNOT NULL\tDEFAULT "  & $value & "," & nl

  template `:=`(dbfield: static string; value: static SomeInteger): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & dbfield & "\t" & "INTEGER\tNOT NULL\tDEFAULT "  & $value & "," & nl

  template `:=`(dbfield: static string; value: static bool): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & dbfield & "\t" & "BOOLEAN\tNOT NULL\tDEFAULT "  & (if $value == "true": "1" else: "0") & "," & nl

  template `:=`(dbfield: static string; value: static string): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & dbfield & "\t" & "TEXT\tNOT NULL\tDEFAULT '"  & $value & "'," & nl

  template `:=`(dbfield: static string; value: typedesc[char]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "VARCHAR(1)," & nl

  template `:=`(dbfield: static string; value: typedesc[SomeFloat]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "REAL," & nl

  template `:=`(dbfield: static string; value: typedesc[SomeInteger]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "INTEGER," & nl

  template `:=`(dbfield: static string; value: typedesc[bool]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "BOOLEAN," & nl

  template `:=`(dbfield: static string; value: typedesc[string]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "TEXT," & nl

  template `:=`(dbfield: static cstring; value: typedesc[char]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "VARCHAR(1)\tUNIQUE," & nl

  template `:=`(dbfield: static cstring; value: typedesc[SomeFloat]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "REAL\tUNIQUE," & nl

  template `:=`(dbfield: static cstring; value: typedesc[SomeInteger]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "INTEGER\tUNIQUE," & nl

  template `:=`(dbfield: static cstring; value: typedesc[bool]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "BOOLEAN\tUNIQUE," & nl

  template `:=`(dbfield: static cstring; value: typedesc[string]): string =
    assert dbfield.len > 0, "Table field name must not be empty string"
    "\t" & $dbfield & "\t" & "TEXT\tUNIQUE," & nl

  var cueri = "CREATE TABLE IF NOT EXISTS " & name & "(" & nl & (
    when defined(postgres): "  id\tINTEGER\tGENERATED BY DEFAULT AS IDENTITY,"
    else: "  id\tINTEGER\tPRIMARY KEY,") & nl
  for field in code: cueri.add field
  cueri.add ");" # http://blog.2ndquadrant.com/postgresql-10-identity-columns
  sql(cueri)


template dropTable*(db; name: string): bool =
  ## Alias for `tryExec(db, sql("DROP TABLE IF EXISTS ?"), name)`.
  ## Requires a `db` of `DbConn` type. Works with Postgres and Sqlite.
  ## Deleted tables can not be restored, be careful.
  assert name.len > 0, "Table name must not be empty string"
  tryExec(db, sql("DROP TABLE IF EXISTS ?" & (when defined(postgres): " CASCADE" else: "")), name)


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
