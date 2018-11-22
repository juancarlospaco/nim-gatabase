## Gatabase
## ========
##
## - Postgres >= 11.
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
  query_begin = sql"BEGIN;"
  query_Env = sql"SHOW ALL;"
  query_commit = sql"COMMIT;"
  query_rollback = sql"ROLLBACK;"
  query_Version = sql"SHOW SERVER_VERSION;"
  query_currentUser = sql"SELECT current_user;"
  query_allUsers = sql"SELECT rolname FROM pg_roles;"
  query_currentDatabase = sql"SELECT current_database();"
  pg_dump = "pg_dump --verbose --no-password --encoding=UTF8 "
  query_allTables = sql"SELECT tablename FROM pg_catalog.pg_tables;"
  query_allSchemas = sql"SELECT nspname FROM pg_catalog.pg_namespace;"
  query_allDatabases = sql"SELECT datname FROM pg_database WHERE datistemplate = false;"
  query_LoggedInUsers = sql"SELECT DISTINCT datname, usename, client_hostname, client_port, query FROM pg_stat_activity;"
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

func newInt8Field(value: int8, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "int8",
                    "pgType": nimTypes2pgTypes["int8"], "pgName": name.normalize})

func newInt16Field(value: int16, name: string, help="", error=""): Field =
  result = Field(%*{"value": value,  "help": help.normalize, "error": error.normalize, "nimType": "int16",
                    "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newInt32Field(value: int32, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "int32",
                    "pgType": nimTypes2pgTypes["int32"], "pgName": name.normalize})

func newIntField(value: int, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "int",
                    "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newFloat32Field(value: float32, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "float32",
                    "pgType": nimTypes2pgTypes["float32"], "pgName": name.normalize})

func newFloatField(value: float, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "float",
                    "pgType": nimTypes2pgTypes["float"], "pgName": name.normalize})

func newBoolField(value: bool, name: string, help="", error=""): Field =
  result = Field(%*{"value": value, "help": help.normalize, "error": error.normalize, "nimType": "bool",
                    "pgType": nimTypes2pgTypes["bool"], "pgName": name.normalize})

func newPDocumentField(value: PDocument, name: string, help="", error=""): Field =
  result = Field(%*{"value": $value, "help": help.normalize, "error": error.normalize, "nimType": "PDocument",
                    "pgType": nimTypes2pgTypes["PDocument"], "pgName": name.normalize})

func newColorField(value: Color, name: string, help="", error=""): Field =
  result = Field(%*{"value": value.int, "help": help.normalize, "error": error.normalize, "nimType": "Color",
                    "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newHashField(value: Hash, name: string, help="", error=""): Field =
  result = Field(%*{"value": value.int,  "help": help.normalize, "error": error.normalize, "nimType": "Hash",
                    "pgType": nimTypes2pgTypes["int"], "pgName": name.normalize})

func newHttpCodeField(value: HttpCode, name: string, help="", error=""): Field =
  result = Field(%*{"value": value.int16, "help": help.normalize, "error": error.normalize, "nimType": "HttpCode",
                    "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newPortField(value: Port, name: string, help="", error=""): Field =
  result = Field(%*{"value": value.int16, "help": help.normalize, "error": error.normalize, "nimType": "Port",
                    "pgType": nimTypes2pgTypes["int16"], "pgName": name.normalize})

func newPegField(value: Peg, name: string, help="", error=""): Field =
  result = Field(%*{"value": $value, "help": help.normalize, "error": error.normalize, "nimType": "Peg",
                    "pgType": nimTypes2pgTypes["string"], "pgName": name.normalize})

proc connect*(this: var Gatabase, debug=false) {.discardable.} =
  ## Open the Database connection, set Encoding to UTF-8, set URI, debug URI.
  assert this.user.len > 1, "Postgres username 'user' must be a non-empty string"
  assert this.password.len > 1, "Postgres 'password' must be a non-empty string"
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
  this.db.getAllRows(query_LoggedInUsers)

template document*(this: Gatabase, what, target, comment: string): untyped =
  ## Document target with comment. Postgres Comment is like Self-Documentation.
  assert what.strip.len > 1, "'what' must not be an empty string."
  assert target.strip.len > 1, "'target' must not an be empty string."
  doAssert what.normalize != "column", "Comments on columns are not allowed."
  if comment.strip.len > 0:
    discard this.db.tryExec(sql("COMMENT ON $1 $2 IS ?;".format(what, target)), comment.strip)

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
  this.db.tryExec(sql(fmt"COMMENT ON COLUMN {tablename}.{columnname} IS '{meta}';"))

proc readMetadata(this: Gatabase, field: Field, columnname, tablename: string): JsonNode =
  ## Field Metadata is JSON read from Postgres Comment. Know a better way?, send Pull Request!.
  ## https://www.postgresql.org/message-id/28332.1074527643%40sss.pgh.pa.us
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  assert columnname.strip.len > 0, "'columnname' must not be an empty string."
  let
    col_query = fmt"select ordinal_position from information_schema.columns where table_name = '{tablename}' and column_name = '{columnname}';"
    col_num = this.db.getRow(sql(col_query))[0]
    meta = this.db.getRow(sql(fmt"select col_description('{tablename}'::regclass, {col_num});"))[0]
  result = meta.parseJson

func getVersion*(this: Gatabase): Row =
  ## Return the Postgres database server Version (SemVer).
  this.db.getRow(query_Version)

func getEnv*(this: Gatabase): Row =
  ## Return the Postgres database server environtment variables.
  this.db.getRow(query_Env)

func getCurrentUser*(this: Gatabase): Row =
  ## Return the current Postgres database user.
  this.db.getRow(query_currentUser)

func listAllUsers*(this: Gatabase): seq[Row] =
  ## Return all users on the Postgres database server.
  this.db.getAllRows(query_allUsers)

func listAllDatabases*(this: Gatabase): seq[Row] =
  ## Return all databases on the Postgres database server.
  this.db.getAllRows(query_allDatabases)

func listAllSchemas*(this: Gatabase): seq[Row] =
  ## Return all schemas on the Postgres database server.
  this.db.getAllRows(query_allSchemas)

func listAllTables*(this: Gatabase): seq[Row] =
  ## Return all tables on the Postgres database server.
  this.db.getAllRows(query_allTables)

func getCurrentDatabase*(this: Gatabase): Row =
  ## Return the current database.
  this.db.getRow(query_currentDatabase)

func createDatabase*(this: Gatabase, dbname, comment: string, owner=this.user, autocommit=true): bool =
  ## Create a new database, with optional comment.
  if not autocommit: this.db.exec(query_begin)
  result = this.db.tryExec(sql(fmt"CREATE DATABASE {dbname} WITH OWNER {owner};"))
  document(this, "DATABASE", dbname, comment)
  if not autocommit:
    if result:
      this.db.exec(query_commit)
    else:
      this.db.exec(query_rollback)

func dropDatabase*(this: Gatabase, dbname: string): bool =
  ## Drop a database if exists.
  this.db.tryExec(sql(fmt"DROP DATABASE IF EXISTS {dbname};"))

func renameDatabase*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a database.
  this.db.tryExec(sql(fmt"ALTER DATABASE {old_name} RENAME TO {new_name};"))

func getTop(this: Gatabase, limit: byte): seq[Row] =
  ## Get Top from current database with limit.
  this.db.getAllRows(sql(fmt"SELECT * FROM current_database() LIMIT {limit};"))

func grantSelect*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant select privileges to a user on a database.
  this.db.tryExec(sql(fmt"GRANT SELECT ON {dbname} TO {user};"))

func grantAll*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant all privileges to a user on a database.
  this.db.tryExec(sql(fmt"GRANT ALL PRIVILEGES ON DATABASE {dbname} TO {user};"))

func createUser*(this: Gatabase, user, password, comment: string, autocommit=true): bool =
  ## Create a new user.
  if not autocommit: this.db.exec(query_begin)
  result = this.db.tryExec(sql(fmt"CREATE USER {user} WITH PASSWORD ?;"), password)
  document(this, "USER", user, comment)
  if not autocommit:
    if result:
      this.db.exec(query_commit)
    else:
      this.db.exec(query_rollback)

func changePasswordUser*(this: Gatabase, user, password: string): bool =
  ## Change the password of a user.
  this.db.tryExec(sql(fmt"ALTER ROLE {user} WITH PASSWORD ?;"), password)

func dropUser*(this: Gatabase, user: string): bool =
  ## Drop a user if exists.
  this.db.tryExec(sql(fmt"DROP USER IF EXISTS {user};"))

func renameUser*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a user.
  this.db.tryExec(sql(fmt"ALTER USER {old_name} RENAME TO {new_name};"))

func createSchema*(this: Gatabase, schemaname, comment: string, autocommit=true): bool =
  ## Create a new schema.
  if not autocommit: this.db.exec(query_begin)
  result = this.db.tryExec(sql(fmt"CREATE SCHEMA IF NOT EXISTS {schemaname};"))
  document(this, "SCHEMA", schemaname, comment)
  if not autocommit:
    if result:
      this.db.exec(query_commit)
    else:
      this.db.exec(query_rollback)

func dropSchema*(this: Gatabase, schemaname: string): bool =
  ## Drop an schema if exists.
  this.db.tryExec(sql(fmt"DROP SCHEMA IF EXISTS {schemaname} CASCADE;"))

proc createTable*(this: Gatabase, tablename: string, fields: seq[Field], comment: string, debug=false, autocommit=true): bool =
  ## Create a new Table with Columns.
  doAssert fields.len > 0, "'fields' must be a non-empty seq[Field]"
  if not autocommit: this.db.exec(query_begin)
  var columns = "\n  id SERIAL PRIMARY KEY"
  for c in fields:
    columns &= ",\n  " & fmt"""{c["pgName"].getStr} {c["pgType"].getStr} DEFAULT {c["value"]}"""
  let query = fmt"CREATE TABLE IF NOT EXISTS {tablename}({columns}); /* {comment} */"
  if debug: echo query
  result = this.db.tryExec(sql(query))
  for field in fields:
    discard this.writeMetadata(field, field["pgName"].getStr, tablename)
    # echo this.readMetadata(field, field["pgName"].getStr, tablename)
  document(this, "TABLE", tablename, comment)
  if not autocommit:
    if result:
      this.db.exec(query_commit)
    else:
      this.db.exec(query_rollback)

func dropTable*(this: Gatabase, tablename: string): bool =
  ## Drop a table if exists.
  this.db.tryExec(sql(fmt"DROP TABLE IF EXISTS {tablename} CASCADE;"))

func renameTable*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a table.
  this.db.tryExec(sql(fmt"ALTER TABLE {old_name} RENAME TO {new_name};"))

func changeAutoVacuumTable*(this: Gatabase, tablename: string, autovacuum_enabled: bool): bool =
  ## Change the Auto-Vacuum setting for a table.
  this.db.tryExec(sql(fmt"ALTER TABLE {tablename} SET (autovacuum_enabled = {autovacuum_enabled});"))

proc backupDatabase*(this: Gatabase, dbname, filename: string, dataOnly=false, inserts=false, debug=false): tuple[output: TaintedString, exitCode: int] =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  let
    a = if dataOnly: "--data-only " else: ""
    b = if inserts: "--inserts " else: ""
    c = fmt"--lock-wait-timeout={this.timeout * 2} "
    d = "--host=" & this.host & " --port=" & $this.port & " --username=" & this.user
    cmd = fmt"{pg_dump}{a}{b}{c}{d} --file={filename.quoteShell} --dbname={dbname}"
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
  echo database.listAllUsers()
  echo database.listAllDatabases()
  echo database.listAllSchemas()
  echo database.listAllTables()
  echo database.getCurrentUser()
  echo database.getCurrentDatabase()
  echo database.getLoggedInUsers()
  # Database
  echo database.createDatabase("testing", "This is a Documentation Comment")
  echo database.grantSelect("testing")
  echo database.grantAll("testing")
  echo database.renameDatabase("testing", "testing2")
  echo database.getTop(3.byte)
  echo database.dropDatabase("testing2")
  # User
  echo database.createUser("pepe", "PaSsW0rD!", "This is a Documentation Comment")
  echo database.changePasswordUser("pepe", "p@ssw0rd")
  echo database.renameUser("pepe", "pepe2")
  echo database.dropUser("pepe2")
  # Schema
  echo database.createSchema("memes", "This is a Documentation Comment", autocommit=false)
  echo database.dropSchema("memes")  # AFAIK Postgres Schemas cant be Renamed?.
  # Fields
  let
    a = newInt8Field(int8.high, "name0", "Help here", "Error here")
    b = newInt16Field(int16.high, "name1", "Help here", "Error here")
    c = newInt32Field(int32.high, "name2", "Help here", "Error here")
    d = newIntField(int.high, "name3", "Help here", "Error here")
    e = newFloat32Field(42.0.float32, "name4", "Help here", "Error here")
    f = newFloatField(666.0.float64, "name5", "Help here", "Error here")
    g = newBoolField(true, "name6", "Help here", "Error here")
  # Tables
  echo database.createTable("table_name", fields = @[a, b, c, d, e, f, g],
                            "This is a Documentation Comment", debug=true)
  echo database.changeAutoVacuumTable("table_name", true)
  echo database.renameTable("table_name", "cats")
  echo database.dropTable("cats")
  # Backups
  echo database.backupDatabase("database", "backup0.sql", debug=true).output
  echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true, debug=true).output

  database.close()
