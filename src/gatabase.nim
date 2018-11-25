## Gatabase
## ========
##
## - Postgres >= 10.
## - UTF-8 encoding.
## - Database user must have a password.
## - Database connection is to hostname not unix socket.
## - Self-Documentation Comments supported.
## - AutoVacuum for Tables supported.
## - Backups for Databases supported.

import
  db_postgres, strformat, strutils, osproc, json, xmldom, uri, tables, colors,
  hashes, httpcore, nativesockets, pegs, subexes


const
  sql_begin = sql"BEGIN;"
  sql_Env = sql"SHOW ALL;"
  sql_commit = sql"COMMIT;"
  sql_rollback = sql"ROLLBACK;"
  sql_pid = sql"select pg_backend_pid();"
  sql_schema = sql"select current_schema();"
  sql_Version = sql"SHOW SERVER_VERSION;"
  sql_currentUser = sql"SELECT current_user;"
  sql_vacuum = sql"VACUUM (VERBOSE, ANALYZE);"
  sql_allUsers = sql"SELECT rolname FROM pg_roles;"
  sql_currentDatabase = sql"SELECT current_database();"
  sql_killActive = sql"SELECT pg_cancel_backend(procpid);"
  sql_killIdle = sql"SELECT pg_terminate_backend(procpid);"
  sql_allTables = sql"SELECT tablename FROM pg_catalog.pg_tables;"
  sql_allSchemas = sql"SELECT nspname FROM pg_catalog.pg_namespace;"
  sql_allDatabases = sql"SELECT datname FROM pg_database WHERE datistemplate = false;"
  sql_LoggedInUsers = sql"SELECT DISTINCT datname, usename, client_hostname, client_port, query FROM pg_stat_activity;"
  sql_caches = sql"select sum(blks_hit)*100/sum(blks_hit+blks_read) as hit_ratio from pg_stat_database;"
  sql_cpuTop = sql"SELECT substring(query, 1, 50) AS short_query, round(total_time::numeric, 2) AS total_time, calls, rows, round(total_time::numeric / calls, 2) AS avg_time, round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
  sql_slowTop = sql"SELECT substring(query, 1, 100) AS short_query, round(total_time::numeric, 2) AS total_time, calls, rows, round(total_time::numeric / calls, 2) AS avg_time, round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY avg_time DESC LIMIT 10;"

  sql_document = "COMMENT ON $1 $2 IS ?;"
  sql_dropDatabase = "DROP DATABASE IF EXISTS $1;"
  sql_renameDatabase = "ALTER DATABASE $1 RENAME TO $2;"
  sql_getTop = "SELECT * FROM current_database() LIMIT $1;"
  sql_grantSelect = "GRANT SELECT ON $1 TO $2;"
  sql_writeMetadata = "COMMENT ON COLUMN $1.$2 IS '$3';"
  sql_ordinalPosition = "select ordinal_position from information_schema.columns where table_name = '$1' and column_name = '$2';"
  sql_description = "select col_description('$1'::regclass, $2);"
  sql_createDatabase = "CREATE DATABASE $1 WITH OWNER $2;"
  sql_grantAll = "GRANT ALL PRIVILEGES ON DATABASE $1 TO $2;"
  sql_createUser = "CREATE USER $1 WITH PASSWORD ?;"
  sql_changePasswordUser = "ALTER ROLE $1 WITH PASSWORD ?;"
  sql_dropUser = "DROP USER IF EXISTS $1;"
  sql_renameUser = "ALTER USER $1 RENAME TO $2;"
  sql_createSchema = "CREATE SCHEMA IF NOT EXISTS $1;"
  sql_renameSchema = "ALTER SCHEMA $1 RENAME TO $2;"
  sql_dropSchema = "DROP SCHEMA IF EXISTS $1 CASCADE;"
  sql_createTable = "CREATE TABLE IF NOT EXISTS $1($2); /* $3 */"
  sql_getAllRows = "select * from $1 limit $2;"
  sql_searchColumns = "SELECT * FROM $1 WHERE $2 = $3;"
  sql_deleteAll = "DELETE FROM $1;"
  sql_deleteValue = "DELETE FROM $1 WHERE $2 = $3;"
  sql_dropTable = "DROP TABLE IF EXISTS $1 CASCADE;"
  sql_renameTable = "ALTER TABLE $1 RENAME TO $2;"
  sql_autoVacuum = "ALTER TABLE $1 SET (autovacuum_enabled = $2);"

  cmd_pgdump = "pg_dump --verbose --no-password --encoding=UTF8 "

  nimTypes2pgTypes = {
    "int8":      "smallint",
    "int16":     "smallint",
    "int32":     "integer",
    "int":       "bigint",
    "float32":   "decimal",
    "float":     "decimal",
    "char":      "char(1)",
    "bool":      "boolean",
    "string":    "text",
    "JsonNode":  "json",
    "PDocument": "xml",
  }.toTable


type
  Gatabase* = object  ## Postgres database object type.
    user*, password*, host*, dbname*, uri*, encoding*: string
    timeout*: byte ## Database connection Timeout, byte type, 1 ~ 255.
    port: int16     ## Database port, int16 type, Postgres default is 5432.
    db*: DbConn   ## Database connection instance.

  Field* = JsonNode  ## Gatabase Field.


func newInt8Field*(value: int8, name: string, help="", error=""): Field =
  ## Database field for an int8 value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "int8", "pgType": nimTypes2pgTypes["int8"], "pgName": name.normalize})

func newInt16Field*(value: int16, name: string, help="", error=""): Field =
  ## Database field for an int16 value, with help and error messages.
  Field(%*{"value": value,  "help": help.normalize, "error": error.normalize,
           "nimType": "int16", "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newInt32Field*(value: int32, name: string, help="", error=""): Field =
  ## Database field for an int32 value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "int32", "pgType": nimTypes2pgTypes["int32"], "pgName": name.normalize})

func newIntField*(value: int, name: string, help="", error=""): Field =
  ## Database field for an int64 value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "int", "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newFloat32Field*(value: float32, name: string, help="", error=""): Field =
  ## Database field for an float32 value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "float32", "pgType": nimTypes2pgTypes["float32"], "pgName": name.normalize})

func newFloatField*(value: float, name: string, help="", error=""): Field =
  ## Database field for an float64 value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "float", "pgType": nimTypes2pgTypes["float"], "pgName": name.normalize})

func newBoolField*(value: bool, name: string, help="", error=""): Field =
  ## Database field for an bool value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "bool", "pgType": nimTypes2pgTypes["bool"], "pgName": name.normalize})

func newPDocumentField*(value: PDocument, name: string, help="", error=""): Field =
  ## Database field for an XML value, with help and error messages.
  Field(%*{"value": $value, "help": help.normalize, "error": error.normalize,
           "nimType": "PDocument", "pgType": nimTypes2pgTypes["PDocument"], "pgName": name.normalize})

func newColorField*(value: Color, name: string, help="", error=""): Field =
  ## Database field for a Color value, with help and error messages.
  Field(%*{"value": value.int, "help": help.normalize, "error": error.normalize,
           "nimType": "Color", "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newHashField*(value: Hash, name: string, help="", error=""): Field =
  ## Database field for an Hash value, with help and error messages.
  Field(%*{"value": value.int,  "help": help.normalize, "error": error.normalize,
           "nimType": "Hash", "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newHttpCodeField*(value: HttpCode, name: string, help="", error=""): Field =
  ## Database field for an HTTP Response Code value, with help and error messages.
  Field(%*{"value": value.int16, "help": help.normalize, "error": error.normalize,
           "nimType": "HttpCode", "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newPortField*(value: Port, name: string, help="", error=""): Field =
  ## Database field for an TCP/UDP Port value, with help and error messages.
  Field(%*{"value": value.int16, "help": help.normalize, "error": error.normalize,
           "nimType": "Port", "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newPegField*(value: Peg, name: string, help="", error=""): Field =
  ## Database field for an PEG value, with help and error messages.
  Field(%*{"value": $value, "help": help.normalize, "error": error.normalize,
           "nimType": "Peg", "pgType": nimTypes2pgTypes["string"], "pgName": name.normalize})

func newStringField*(value: string, name: string, help="", error=""): Field =
  ## Database field for an string value, with help and error messages.
  Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
           "nimType": "string", "pgType": nimTypes2pgTypes["string"], "pgName": name.normalize})


proc connect*(this: var Gatabase, debug=false) {.discardable.} =
  ## Open the Database connection, set Encoding to UTF-8, set URI, debug URI.
  assert this.user.len > 1, "Postgres username 'user' must be a non-empty string"
  assert this.password.len > 3, "Postgres 'password' must be a non-empty string"
  assert this.host.len > 1, "Postgres hostname 'host' must be a non-empty string"
  assert this.dbname.len > 1, "Postgres DB 'dbname' must be a non-empty string"
  assert this.timeout.int > 3, "Postgres 'timeout' must be a non-zero byte (>3)"
  this.encoding = "UTF8"
  this.uri = fmt"postgresql://{this.user}:{this.password}@{this.host}:{this.port}/{this.dbname}?connect_timeout={this.timeout}"
  this.db = db_postgres.open(
    "", "", "",
    fmt"host={this.host} port={this.port} dbname={this.dbname} user={this.user} password={this.password} connect_timeout={this.timeout}")
  doAssert this.db.setEncoding(this.encoding), "Failed to set Encoding to UTF-8"
  if debug: echo this.uri

func close*(this: Gatabase) {.discardable, inline.} =
  ## Close the Database connection.
  this.db.close()

func getLoggedInUsers*(this: Gatabase): seq[Row] =
  ## Return all active logged-in users.
  this.db.getAllRows(sql_LoggedInUsers)

func getCaches*(this: Gatabase): seq[Row] =
  ## Return all the Caches.
  this.db.getAllRows(sql_caches)

func killCurrentQuery*(this: Gatabase): seq[Row] =
  ## Kill all the active running Queries.
  this.db.getAllRows(sql_killActive)

func killIdleQuery*(this: Gatabase): seq[Row] =
  ## Kill all the diel non-running Queries.
  this.db.getAllRows(sql_killIdle)

func forceVacuum*(this: Gatabase): seq[Row] =
  ## Kill all the diel non-running Queries.
  this.db.getAllRows(sql_vacuum)

func cpuTop*(this: Gatabase): seq[Row] =
  ## Return Top most CPU intensive queries.
  this.db.getAllRows(sql_cpuTop)

func slowTop*(this: Gatabase): seq[Row] =
  ## Return Top most time consuming slow queries.
  this.db.getAllRows(sql_slowTop)

func forceCommit*(this: Gatabase): bool =
  ## Delete all from table.
  this.db.tryExec(sql_commit)

func forceRollback*(this: Gatabase): bool =
  ## Delete all from table.
  this.db.tryExec(sql_rollback)

template document*(this: Gatabase, what, target, comment: string): untyped =
  ## Document target with comment. Postgres Comment is like Self-Documentation.
  assert what.strip.len > 1, "'what' must not be an empty string."
  assert target.strip.len > 1, "'target' must not an be empty string."
  doAssert what.normalize != "column", "Comments on columns are not allowed."
  if comment.strip.len > 0:
    discard this.db.tryExec(sql(sql_document.format(what, target)), comment.strip)

func writeMetadata(this: Gatabase, field: Field, columnname, tablename: string): bool =
  ## Field Metadata is converted to JSON & stored as Postgres Comment. Know a better way?, send Pull Request!.
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  assert columnname.strip.len > 0, "'columnname' must not be an empty string."
  var meta: string
  meta.toUgly(%*{
    "help":    field["help"],
    "error":   field["error"],
    "pgType":  field["pgType"],
    "nimType": field["nimType"],
    "pgName":  field["pgName"]
  })
  this.db.tryExec(sql(sql_writeMetadata.format(tablename, columnname, meta)))

proc readMetadata(this: Gatabase, field: Field, columnname, tablename: string): JsonNode =
  ## Field Metadata is JSON read from Postgres Comment.
  ## https://www.postgresql.org/message-id/28332.1074527643%40sss.pgh.pa.us
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  assert columnname.strip.len > 0, "'columnname' must not be an empty string."
  let col_num = this.db.getRow(sql(sql_ordinalPosition.format(tablename, columnname)))[0]
  this.db.getRow(sql(sql_description.format(tablename, col_num)))[0].parseJson

func getVersion*(this: Gatabase): Row =
  ## Return the Postgres database server Version (SemVer).
  this.db.getRow(sql_Version)

func getEnv*(this: Gatabase): Row =
  ## Return the Postgres database server environtment variables.
  this.db.getRow(sql_Env)

func getPid*(this: Gatabase): Row =
  ## Return the Postgres database server Process ID.
  this.db.getRow(sql_pid)

func getCurrentUser*(this: Gatabase): Row =
  ## Return the current Postgres database user.
  this.db.getRow(sql_currentUser)

func listAllUsers*(this: Gatabase): seq[Row] =
  ## Return all users on the Postgres database server.
  this.db.getAllRows(sql_allUsers)

func listAllDatabases*(this: Gatabase): seq[Row] =
  ## Return all databases on the Postgres database server.
  this.db.getAllRows(sql_allDatabases)

func listAllSchemas*(this: Gatabase): seq[Row] =
  ## Return all schemas on the Postgres database server.
  this.db.getAllRows(sql_allSchemas)

func listAllTables*(this: Gatabase): seq[Row] =
  ## Return all tables on the Postgres database server.
  this.db.getAllRows(sql_allTables)

func getCurrentDatabase*(this: Gatabase): Row =
  ## Return the current database.
  this.db.getRow(sql_currentDatabase)

func getCurrentSchema*(this: Gatabase): Row =
  ## Return the current schema.
  this.db.getRow(sql_schema)

func createDatabase*(this: Gatabase, dbname, comment: string, owner=this.user, autocommit=true): bool =
  ## Create a new database, with optional comment.
  if not autocommit: this.db.exec(sql_begin)
  result = this.db.tryExec(sql(sql_createDatabase.format(dbname, owner)))
  document(this, "DATABASE", dbname, comment)
  if not autocommit:
    if result:
      this.db.exec(sql_commit)
    else:
      this.db.exec(sql_rollback)

func dropDatabase*(this: Gatabase, dbname: string): bool =
  ## Drop a database if exists.
  this.db.tryExec(sql(sql_dropDatabase.format(dbname)))

func renameDatabase*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a database.
  this.db.tryExec(sql(sql_renameDatabase.format(old_name, new_name)))

func getTop(this: Gatabase, limit: byte): seq[Row] =
  ## Get Top from current database with limit.
  this.db.getAllRows(sql(sql_getTop.format(limit)))

func grantSelect*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant select privileges to a user on a database.
  this.db.tryExec(sql(sql_grantSelect.format(dbname, user)))

func grantAll*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant all privileges to a user on a database.
  this.db.tryExec(sql(sql_grantAll.format(dbname, user)))

func createUser*(this: Gatabase, user, password, comment: string, autocommit=true): bool =
  ## Create a new user.
  if not autocommit: this.db.exec(sql_begin)
  result = this.db.tryExec(sql(sql_createUser.format(user)), password)
  document(this, "USER", user, comment)
  if not autocommit:
    if result:
      this.db.exec(sql_commit)
    else:
      this.db.exec(sql_rollback)

func changePasswordUser*(this: Gatabase, user, password: string): bool =
  ## Change the password of a user.
  this.db.tryExec(sql(sql_changePasswordUser.format(user) ), password)

func dropUser*(this: Gatabase, user: string): bool =
  ## Drop a user if exists.
  this.db.tryExec(sql(sql_dropUser.format(user)))

func renameUser*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a user.
  this.db.tryExec(sql(sql_renameUser.format(old_name, new_name)))

func createSchema*(this: Gatabase, schemaname, comment: string, autocommit=true): bool =
  ## Create a new schema.
  if not autocommit: this.db.exec(sql_begin)
  result = this.db.tryExec(sql(sql_createSchema.format(schemaname)))
  document(this, "SCHEMA", schemaname, comment)
  if not autocommit:
    if result:
      this.db.exec(sql_commit)
    else:
      this.db.exec(sql_rollback)

func renameSchema*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename an schema.
  this.db.tryExec(sql(sql_renameSchema.format(old_name, new_name)))

func dropSchema*(this: Gatabase, schemaname: string): bool =
  ## Drop an schema if exists.
  this.db.tryExec(sql(sql_dropSchema.format(schemaname)))

proc createTable*(this: Gatabase, tablename: string, fields: seq[Field], comment: string, debug=false, autocommit=true): bool =
  ## Create a new Table with Columns, Values, Comments, Metadata, etc.
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  doAssert fields.len > 0, "'fields' must be a non-empty seq[Field]"
  if not autocommit: this.db.exec(sql_begin)
  var columns = "\n  id SERIAL PRIMARY KEY"
  for c in fields:
    columns &= ",\n  " & fmt"""{c["pgName"].getStr} {c["pgType"].getStr} DEFAULT {c["value"]}"""
  let query = sql_createTable.format(tablename, columns, comment)
  if debug: echo query
  result = this.db.tryExec(sql(query))
  for field in fields:
    discard this.writeMetadata(field, field["pgName"].getStr, tablename)
    # echo this.readMetadata(field, field["pgName"].getStr, tablename)
  document(this, "TABLE", tablename, comment)
  if not autocommit:
    if result:
      this.db.exec(sql_commit)
    else:
      this.db.exec(sql_rollback)

func getAllRows*(this: Gatabase, tablename: string, limit: byte): seq[Row] =
  ## Get all Rows from table.
  this.db.getAllRows(sql(sql_getAllRows.format(tablename, limit)))

func searchColumns*(this: Gatabase, tablename, columnname, value: string): seq[Row] =
  ## Get all Rows from table.
  this.db.getAllRows(sql(sql_searchColumns.format(tablename, columnname, value)))

func deleteAllFromTable*(this: Gatabase, tablename: string): bool =
  ## Delete all from table.
  this.db.tryExec(sql(sql_deleteAll.format(tablename)))

func deleteValueFromTable*(this: Gatabase, tablename, columnname, value: string,): bool =
  ## Delete all from table.
  this.db.tryExec(sql(sql_deleteValue.format(tablename, columnname, value)))

func dropTable*(this: Gatabase, tablename: string): bool =
  ## Drop a table if exists.
  this.db.tryExec(sql(sql_dropTable.format(tablename)))

func renameTable*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a table.
  assert old_name.strip.len > 1, "'old_name' must not be an empty string."
  assert new_name.strip.len > 1, "'new_name' must not be an empty string."
  this.db.tryExec(sql(sql_renameTable.format(old_name, new_name)))

func changeAutoVacuumTable*(this: Gatabase, tablename: string, enabled: bool): bool =
  ## Change the Auto-Vacuum setting for a table.
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  this.db.tryExec(sql(sql_autoVacuum.format(tablename, enabled)))

proc backupDatabase*(this: Gatabase, dbname, filename: string, dataOnly=false, inserts=false, debug=false): tuple[output: TaintedString, exitCode: int] =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  assert dbname.strip.len > 1, "'dbname' must not be an empty string."
  assert filename.strip.len > 5, "'filename' must not be an empty string."
  let
    a = if dataOnly: "--data-only " else: ""
    b = if inserts: "--inserts " else: ""
    c = fmt"--lock-wait-timeout={this.timeout * 2} "
    d = "--host=" & this.host & " --port=" & $this.port & " --username=" & this.user
    cmd = fmt"{cmd_pgdump}{a}{b}{c}{d} --file={filename.quoteShell} --dbname={dbname}"
  if debug: echo cmd
  execCmdEx(cmd)




when isMainModule:
  # Database init (change to your user and password).
  var database = Gatabase(user: "juan", password: "juan", host: "localhost",
                          dbname: "database", port: 5432, timeout: 10)
  database.connect(debug=true)
  # Engine
  echo database.getVersion()
  echo database.getEnv()
  echo database.getPid()
  echo database.listAllUsers()
  echo database.listAllDatabases()
  echo database.listAllSchemas()
  echo database.listAllTables()
  echo database.getCurrentUser()
  echo database.getCurrentDatabase()
  echo database.getCurrentSchema()
  echo database.getLoggedInUsers()
  echo database.forceCommit()
  echo database.forceRollback()
  # Database
  echo database.createDatabase("testing", "This is a Documentation Comment")
  echo database.grantSelect("testing")
  echo database.grantAll("testing")
  echo database.renameDatabase("testing", "testing2")
  echo database.getTop(3)
  echo database.dropDatabase("testing2")
  # User
  echo database.createUser("pepe", "PaSsW0rD!", "This is a Documentation Comment")
  echo database.changePasswordUser("pepe", "p@ssw0rd")
  echo database.renameUser("pepe", "pepe2")
  echo database.dropUser("pepe2")
  # Schema
  echo database.createSchema("memes", "This is a Documentation Comment", autocommit=false)
  echo database.renameSchema("memes", "foo")
  echo database.dropSchema("foo")
  # Fields
  let
    a = newInt8Field(int8.high, "name0", "Help here", "Error here")
    b = newInt16Field(int16.high, "name1", "Help here", "Error here")
    c = newInt32Field(int32.high, "name2", "Help here", "Error here")
    d = newIntField(int.high, "name3", "Help here", "Error here")
    e = newFloat32Field(42.0.float32, "name4", "Help here", "Error here")
    f = newFloatField(666.0.float64, "name5", "Help here", "Error here")
    g = newBoolField(true, "name6", "Help here", "Error here")
  assert a is Field
  assert b is Field
  # Tables
  echo database.createTable("table_name", fields = @[a, b, c, d, e, f, g],
                            "This is a Documentation Comment", debug=true)
  echo database.getAllRows("table_name", limit=255)
  echo database.searchColumns("table_name", "name0", $int8.high)
  echo database.changeAutoVacuumTable("table_name", true)
  echo database.renameTable("table_name", "cats")
  echo database.dropTable("cats")
  # Backups
  echo database.backupDatabase("database", "backup0.sql").output
  echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true, debug=true).output

  database.close()
