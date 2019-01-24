## Gatabase
## ========
##
## .. image:: https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg
# https://github.com/coleifer/peewee/blob/035b7b55a80dc70a3f27dd5f2a4900908e541c49/peewee.py
# https://github.com/coleifer/peewee/blob/2.1.3/peewee.py
# http://docs.peewee-orm.com/en/2.10.2/peewee/querying.html
# https://github.com/Araq/blog/blob/master/ormin.rst#ormin
# https://evertpot.com/writing-sql-for-postgres-mysql-sqlite
# https://gist.github.com/gipi/1521252
# https://nim-lang.org/docs/db_postgres.html
# https://nim-lang.org/docs/db_sqlite.html

import strformat, strutils, json, uri, tables, osproc
from nativesockets import Port

when not defined(noFields):
  import xmldom, colors, hashes, httpcore, pegs, subexes

when defined(sqlite): import db_sqlite
else:                 import db_postgres


# SQL common to both Postgres and SQLite ######################################


const
  gatabaseVersion*    = 0.2                   ## Gatabase Version (SemVer).
  gatabaseIsPostgres* = not defined(sqlite)   ## Gatabase was compiled for Postgres?
  gatabaseIsFields*   = not defined(noFields) ## Gatabase was compiled for Fields?
  sql_begin         = sql"BEGIN;"
  sql_commit        = sql"COMMIT;"
  sql_rollback      = sql"ROLLBACK;"
  sql_createTable   = "CREATE TABLE IF NOT EXISTS $1($2); /* $3 */"
  sql_getAllRows    = "select $1 * from $2 limit $3 offset $4;"
  sql_searchColumns = "SELECT $1 * FROM $2 WHERE $3 = $4 limit $5 offset $6;"
  sql_deleteAll     = "DELETE FROM $1 limit $2 offset $3;"
  sql_deleteValue   = "DELETE FROM $1 WHERE $2 = $3 limit $4 offset $5;"
  sql_renameTable   = "ALTER TABLE $1 RENAME TO $2;"
  sql_allTables     = sql"SELECT tablename FROM pg_catalog.pg_tables;"

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
  }.toTable  ## Nim Types to Postgres Types "conversion" table.


# SQL that are different for Postgres and SQLite but still works on both ######


  sql_epochnow =
    when defined(sqlite): "(strftime('%s', 'now'))"     # SQLite 3 epoch now.
    else:                 "(extract(epoch from now()))" # Postgres epoch now.
  sql_Version =
    when defined(sqlite): sql"select sqlite_version();"
    else:                 sql"SHOW SERVER_VERSION;"
  sql_vacuum =
    when defined(sqlite): sql"VACUUM;"
    else:                 sql"VACUUM (VERBOSE, ANALYZE);"
  sql_dropTable =
    when defined(sqlite): "DROP TABLE IF EXISTS $1;"
    else:                 "DROP TABLE IF EXISTS $1 CASCADE;"

  cmd_backup =
    when defined(sqlite): "sqlite3 -readonly -echo "         ## Command to Backup SQLite Database.
    else: "pg_dump --verbose --no-password --encoding=UTF8 " ## Command to Backup Postgres Database.

  # Migrated from NimWC to clean out code.

  personTable_simple = """
    create table if not exists $$1(
      id         integer       primary key,
      name       varchar(60)   not null,
      password   varchar(300)  not null
    );"""

  personTable_medium = """
    create table if not exists $$1(
      id         integer       primary key,
      name       varchar(60)   not null,
      password   varchar(300)  not null,
      email      varchar(254)  not null,
      creation   timestamp     not null           default $1,
      modified   timestamp     not null           default $1,
      salt       varchar(128)  not null,
      status     varchar(30)   not null,
      timezone   varchar(100),
      secretUrl  varchar(250),
      lastOnline timestamp     not null           default $1
    );""".format(sql_epochnow)

  personTable_full = """
    create table if not exists $$1(
      id         integer       primary key,
      name       varchar(60)   not null,
      password   varchar(300)  not null,
      email      varchar(254)  not null,
      creation   timestamp     not null           default $1,
      modified   timestamp     not null           default $1,
      salt       varchar(128)  not null,
      status     varchar(30)   not null,
      timezone   varchar(100),
      secretUrl  varchar(250),
      lastOnline timestamp     not null           default $1
    );""".format(sql_epochnow)  # TODO TBD

  # Migrated from NimWC to clean out code.


# SQL for Postgres only, or that I dont know how to do it on SQLite ###########


when not defined(sqlite):
  {.hint: "Compile with -d:sqlite to enable SQLite and disable Postgres.".}
  const
    sql_hstore             = sql"CREATE EXTENSION hstore;" # Postgres HStore plugin
    sql_Env                = sql"SHOW ALL;"
    sql_pid                = sql"select pg_backend_pid();"
    sql_schema             = sql"select current_schema();"
    sql_currentUser        = sql"SELECT current_user;"
    sql_allUsers           = sql"SELECT rolname FROM pg_roles;"
    sql_currentDatabase    = sql"SELECT current_database();"
    sql_forceReloadConfig  = sql"select pg_reload_conf();"
    sql_allSchemas         = sql"SELECT nspname FROM pg_catalog.pg_namespace;"
    sql_allDatabases       = sql"SELECT datname FROM pg_database WHERE datistemplate = false;"
    sql_LoggedInUsers      = sql"SELECT DISTINCT datname, usename, client_hostname, client_port, query FROM pg_stat_activity;"
    sql_caches             = sql"select sum(blks_hit)*100/sum(blks_hit+blks_read) as hit_ratio from pg_stat_database;"
    sql_cpuTop             = sql"SELECT substring(query, 1, 50) AS short_query, round(total_time::numeric, 2) AS total_time, calls, rows, round(total_time::numeric / calls, 2) AS avg_time, round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
    sql_slowTop            = sql"SELECT substring(query, 1, 100) AS short_query, round(total_time::numeric, 2) AS total_time, calls, rows, round(total_time::numeric / calls, 2) AS avg_time, round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu FROM pg_stat_statements ORDER BY avg_time DESC LIMIT 10;"
    sql_IsUserConnected    = "SELECT datname FROM pg_stat_activity WHERE usename = '$1';"
    sql_DatabaseSize       = "SELECT pg_database_size($1);"
    sql_TableSize          = "select pg_relation_size('$1');"
    sql_killActive         = "SELECT pg_cancel_backend($1);"
    sql_killIdle           = "SELECT pg_terminate_backend($1);"
    sql_document           = "COMMENT ON $1 $2 IS ?;"
    sql_getTop             = "SELECT $1 * FROM current_database() LIMIT $2 OFFSET $3;"
    sql_writeMetadata      = "COMMENT ON COLUMN $1.$2 IS '$3';"
    sql_ordinalPosition    = "select ordinal_position from information_schema.columns where table_name = '$1' and column_name = '$2';"
    sql_description        = "select col_description('$1'::regclass, $2);"
    sql_createSchema       = "CREATE SCHEMA IF NOT EXISTS $1;"
    sql_renameSchema       = "ALTER SCHEMA $1 RENAME TO $2;"
    sql_dropSchema         = "DROP SCHEMA IF EXISTS $1 CASCADE;"
    sql_dropDatabase       = "DROP DATABASE IF EXISTS $1;"
    sql_renameDatabase     = "ALTER DATABASE $1 RENAME TO $2;"
    sql_grantSelect        = "GRANT SELECT ON $1 TO $2;"
    sql_grantAll           = "GRANT ALL PRIVILEGES ON DATABASE $1 TO $2;"
    sql_createDatabase     = "CREATE DATABASE $1 WITH OWNER $2;"
    sql_createUser         = "CREATE USER $1 WITH PASSWORD ?;"
    sql_changePasswordUser = "ALTER ROLE $1 WITH PASSWORD ?;"
    sql_dropUser           = "DROP USER IF EXISTS $1;"
    sql_renameUser         = "ALTER USER $1 RENAME TO $2;"
    sql_autoVacuum         = "ALTER TABLE $1 SET (autovacuum_enabled = $2);"


type
  Gatabase* = object  ## Database object type.
    user*, password*, host*, dbname*, uri*, encoding*: string
    timeout*: byte ## Database connection Timeout, byte type, 1 ~ 255.
    port: Port     ## Database port, Port type, Postgres default is 5432.
    db*: DbConn   ## Database connection instance.

when not defined(sqlite):
  template document*(this: Gatabase, what, target, comment: string): untyped =
    ## Document target with comment. Postgres Comment is like Self-Documentation.
    assert what.strip.len > 1, "'what' must not be an empty string."
    assert target.strip.len > 1, "'target' must not an be empty string."
    doAssert what.normalize != "column", "Comments on columns are not allowed."
    if comment.strip.len > 0:
      when not defined(release): debugEcho sql_document.format(what, target)
      discard this.db.tryExec(sql(sql_document.format(what, target)), comment.strip)

when not defined(noFields) and not defined(sqlite):
  {.hint: "Compile with -d:noFields to disable Fields feature (smaller binary)".}
  type Field* = JsonNode  ## Gatabase Field.

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

  func newPegField*(value: Peg, name: string, help="", error=""): Field =
    ## Database field for an PEG value, with help and error messages.
    Field(%*{"value": $value, "help": help.normalize, "error": error.normalize,
             "nimType": "Peg", "pgType": nimTypes2pgTypes["string"], "pgName": name.normalize})

  func newStringField*(value: string, name: string, help="", error=""): Field =
    ## Database field for an string value, with help and error messages.
    Field(%*{"value": value, "help": help.normalize, "error": error.normalize,
             "nimType": "string", "pgType": nimTypes2pgTypes["string"], "pgName": name.normalize})

  func writeMetadata(this: Gatabase, field: Field, columnname, tablename: string): auto =
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

  func createTable*(this: Gatabase, tablename: string, fields: seq[Field], comment: string, autocommit=true): auto =
    ## Create a new Table with Columns, Values, Comments, Metadata, etc.
    assert tablename.strip.len > 0, "'tablename' must not be an empty string."
    doAssert fields.len > 0, "'fields' must be a non-empty sequence @[Field]"
    when not defined(sqlite):
      if not autocommit: this.db.exec(sql_begin)
    var columns = "\n  id SERIAL PRIMARY KEY"
    for c in fields:
      columns &= ",\n  " & fmt"""{c["pgName"].getStr}\t{c["pgType"].getStr}\tDEFAULT {c["value"]}"""
    let query = sql_createTable.format(tablename, columns, comment)
    when not defined(release): debugEcho query
    result = this.db.tryExec(sql(query))
    when not defined(sqlite):
      for field in fields:
        discard this.writeMetadata(field, field["pgName"].getStr, tablename)
        # echo this.readMetadata(field, field["pgName"].getStr, tablename)
      document(this, "TABLE", tablename, comment)
      if not autocommit:
        if result:
          this.db.exec(sql_commit)
        else:
          this.db.exec(sql_rollback)


proc connect*(this: var Gatabase) {.discardable.} =
  ## Open the Database connection, set Encoding to UTF-8, set URI, debug URI.
  assert this.host.len > 1, "Hostname must be a non-empty string"
  this.encoding = "UTF8"
  when defined(sqlite):
    this.uri = "sqlite://" & $this.host
    this.db = db_sqlite.open($this.host, "", "", "")
  else:
    assert this.user.len > 1,     "Username must be a non-empty string"
    assert this.password.len > 3, "Password must be a non-empty string"
    assert this.dbname.len > 1,   "DBname must be a non-empty string"
    assert this.timeout.int > 3,   "Timeout must be a non-zero positive byte (> 3)"
    this.uri = fmt"postgresql://{this.user}:{this.password}@{this.host}:{this.port.int}/{this.dbname}?connect_timeout={this.timeout.int16}"
    this.db = db_postgres.open("", "", "",
      fmt"host={this.host} port={this.port.int} dbname={this.dbname} user={this.user} password={this.password} connect_timeout={this.timeout.int16}")
  doAssert this.db.setEncoding(this.encoding), "Failed to set Encoding to UTF-8"
  when not defined(release): echo this.uri

func close*(this: Gatabase) {.discardable, inline.} =
  ## Close the Database connection.
  this.db.close()

func getLoggedInUsers*(this: Gatabase): auto =
  ## Return all active logged-in users.
  when not defined(release): debugEcho sql_LoggedInUsers.repr
  this.db.getAllRows(sql_LoggedInUsers)

func getCaches*(this: Gatabase): auto =
  ## Return all the Caches.
  when not defined(release): debugEcho sql_caches.repr
  this.db.getAllRows(sql_caches)

func killQuery*(this: Gatabase, pid: string): auto =
  ## Kill all the active running Queries.
  when not defined(release): debugEcho sql_killActive.format(pid)
  this.db.getAllRows(sql(sql_killActive.format(pid)))

func killIdleQuery*(this: Gatabase, pid: string): auto =
  ## Kill all the diel non-running Queries.
  when not defined(release): debugEcho sql_killIdle.format(pid)
  this.db.getAllRows(sql(sql_killIdle.format(pid)))

func forceVacuum*(this: Gatabase): auto =
  ## Kill all the diel non-running Queries.
  when not defined(release): debugEcho sql_vacuum.repr
  this.db.getAllRows(sql_vacuum)

func cpuTop*(this: Gatabase): auto =
  ## Return Top most CPU intensive queries.
  when not defined(release): debugEcho sql_cpuTop.repr
  this.db.getAllRows(sql_cpuTop)

func slowTop*(this: Gatabase): auto =
  ## Return Top most time consuming slow queries.
  when not defined(release): debugEcho sql_slowTop.repr
  this.db.getAllRows(sql_slowTop)

func forceCommit*(this: Gatabase): auto =
  ## Delete all from table.
  when not defined(release): debugEcho sql_commit.repr
  this.db.tryExec(sql_commit)

func forceRollback*(this: Gatabase): auto =
  ## Delete all from table.
  when not defined(release): debugEcho sql_rollback.repr
  this.db.tryExec(sql_rollback)

when not defined(sqlite):

  func enableHstore*(this: Gatabase): auto =
    ## Enable Postgres Extension HSTORE that comes built-in but disabled.
    when not defined(release): debugEcho sql_hstore.repr
    this.db.tryExec(sql_hstore)

func getVersion*(this: Gatabase): auto =
  ## Return the Postgres database server Version (SemVer).
  when not defined(release): debugEcho sql_Version.repr
  this.db.getRow(sql_Version)

func getEnv*(this: Gatabase): auto =
  ## Return the Postgres database server environtment variables.
  when not defined(release): debugEcho sql_Env.repr
  this.db.getRow(sql_Env)

func getPid*(this: Gatabase): auto =
  ## Return the Postgres database server Process ID.
  when not defined(release): debugEcho sql_pid.repr
  this.db.getRow(sql_pid)

func getCurrentUser*(this: Gatabase): auto =
  ## Return the current Postgres database user.
  when not defined(release): debugEcho sql_currentUser.repr
  this.db.getRow(sql_currentUser)

func forceReloadConfig*(this: Gatabase): auto =
  ## Force reloading PostgreSQL configuration files without Restarting the Server.
  when not defined(release): debugEcho sql_forceReloadConfig.repr
  this.db.getRow(sql_forceReloadConfig)

func getDatabaseSize*(this: Gatabase, databasename = "current_database()"): auto =
  ## Return the current Postgres database size in bytes.
  when not defined(release): debugEcho sql_DatabaseSize.format(databasename)
  this.db.getRow(sql(sql_DatabaseSize.format(databasename)))

func getTableSize*(this: Gatabase, tablename: string): auto =
  ## Return the current Postgres table size in bytes.
  when not defined(release): debugEcho sql_TableSize.format(tablename)
  this.db.getRow(sql(sql_TableSize.format(tablename)))

func isUserConnected*(this: Gatabase, username: string): auto =
  ## Return the current Postgres table size in bytes.
  when not defined(release): debugEcho sql_IsUserConnected.format(username)
  this.db.getRow(sql(sql_IsUserConnected.format(username)))

func listAllUsers*(this: Gatabase): auto =
  ## Return all users on the Postgres database server.
  when not defined(release): debugEcho sql_allUsers.repr
  this.db.getAllRows(sql_allUsers)

func listAllDatabases*(this: Gatabase): auto =
  ## Return all databases on the Postgres database server.
  when not defined(release): debugEcho sql_allDatabases.repr
  this.db.getAllRows(sql_allDatabases)

func listAllSchemas*(this: Gatabase): auto =
  ## Return all schemas on the Postgres database server.
  when not defined(release): debugEcho sql_allSchemas.repr
  this.db.getAllRows(sql_allSchemas)

func listAllTables*(this: Gatabase): auto =
  ## Return all tables on the Postgres database server.
  when not defined(release): debugEcho sql_allTables.repr
  this.db.getAllRows(sql_allTables)

func getCurrentDatabase*(this: Gatabase): auto =
  ## Return the current database.
  when not defined(release): debugEcho sql_currentDatabase.repr
  this.db.getRow(sql_currentDatabase)

func getCurrentSchema*(this: Gatabase): auto =
  ## Return the current schema.
  when not defined(release): debugEcho sql_schema.repr
  this.db.getRow(sql_schema)

func createDatabase*(this: Gatabase, dbname, comment: string, owner=this.user, autocommit=true): auto =
  ## Create a new database, with optional comment.
  when not defined(sqlite):
    if not autocommit: this.db.exec(sql_begin)
  when not defined(release): debugEcho sql_createDatabase.format(dbname, owner)
  result = this.db.tryExec(sql(sql_createDatabase.format(dbname, owner)))
  when not defined(sqlite):
    document(this, "DATABASE", dbname, comment)
    if not autocommit:
      if result:
        this.db.exec(sql_commit)
      else:
        this.db.exec(sql_rollback)

func dropDatabase*(this: Gatabase, dbname: string): auto =
  ## Drop a database if exists.
  when not defined(release): debugEcho sql_dropDatabase.format(dbname)
  this.db.tryExec(sql(sql_dropDatabase.format(dbname)))

func renameDatabase*(this: Gatabase, old_name, new_name: string): auto =
  ## Rename a database.
  assert old_name.strip.len > 1, "'old_name' must not be an empty string."
  assert new_name.strip.len > 1, "'new_name' must not be an empty string."
  when not defined(release): debugEcho sql_renameDatabase.format(old_name, new_name)
  this.db.tryExec(sql(sql_renameDatabase.format(old_name, new_name)))

func grantSelect*(this: Gatabase, dbname: string, user="PUBLIC"): auto =
  ## Grant select privileges to a user on a database.
  when not defined(release): debugEcho sql_grantSelect.format(dbname, user)
  this.db.tryExec(sql(sql_grantSelect.format(dbname, user)))

func grantAll*(this: Gatabase, dbname: string, user="PUBLIC"): auto =
  ## Grant all privileges to a user on a database.
  when not defined(release): debugEcho sql_grantAll.format(dbname, user)
  this.db.tryExec(sql(sql_grantAll.format(dbname, user)))

func createUser*(this: Gatabase, user, password, comment: string, autocommit=true): auto =
  ## Create a new user.
  when not defined(sqlite):
    if not autocommit: this.db.exec(sql_begin)
  when not defined(release): debugEcho sql_createUser.format(user)
  result = this.db.tryExec(sql(sql_createUser.format(user)), password)
  when not defined(sqlite):
    document(this, "USER", user, comment)
    if not autocommit:
      if result:
        this.db.exec(sql_commit)
      else:
        this.db.exec(sql_rollback)

func changePasswordUser*(this: Gatabase, user, password: string): auto =
  ## Change the password of a user.
  when not defined(release): debugEcho sql_changePasswordUser.format(user)
  this.db.tryExec(sql(sql_changePasswordUser.format(user)), password)

func dropUser*(this: Gatabase, user: string): auto =
  ## Drop a user if exists.
  when not defined(release): debugEcho sql_dropUser.format(user)
  this.db.tryExec(sql(sql_dropUser.format(user)))

func renameUser*(this: Gatabase, old_name, new_name: string): auto =
  ## Rename a user.
  assert old_name.strip.len > 1, "'old_name' must not be an empty string."
  assert new_name.strip.len > 1, "'new_name' must not be an empty string."
  when not defined(release): debugEcho sql_renameUser.format(old_name, new_name)
  this.db.tryExec(sql(sql_renameUser.format(old_name, new_name)))

func createSchema*(this: Gatabase, schemaname, comment: string, autocommit=true): auto =
  ## Create a new schema.
  when not defined(sqlite):
    if not autocommit: this.db.exec(sql_begin)
  when not defined(release): debugEcho sql_createSchema.format(schemaname)
  result = this.db.tryExec(sql(sql_createSchema.format(schemaname)))
  when not defined(sqlite):
    document(this, "SCHEMA", schemaname, comment)
    if not autocommit:
      if result:
        this.db.exec(sql_commit)
      else:
        this.db.exec(sql_rollback)

func renameSchema*(this: Gatabase, old_name, new_name: string): auto =
  ## Rename an schema.
  assert old_name.strip.len > 1, "'old_name' must not be an empty string."
  assert new_name.strip.len > 1, "'new_name' must not be an empty string."
  when not defined(release): debugEcho sql_renameSchema.format(old_name, new_name)
  this.db.tryExec(sql(sql_renameSchema.format(old_name, new_name)))

func dropSchema*(this: Gatabase, schemaname: string): auto =
  ## Drop an schema if exists.
  when not defined(release): debugEcho sql_dropSchema.format(schemaname)
  this.db.tryExec(sql(sql_dropSchema.format(schemaname)))

func getTop(this: Gatabase, limit=int.high, offset=0, `distinct`=false): auto =
  ## Get Top from current database with limit.
  when not defined(release): debugEcho sql_getTop.format(if `distinct`: "distinct" else: "", limit, offset)
  this.db.getAllRows(sql(sql_getTop.format(if `distinct`: "distinct" else: "", limit, offset)))

func getAllRows*(this: Gatabase, tablename: string, limit=int.high, offset=0, `distinct`=false): auto =
  ## Get all Rows from table.
  when not defined(release): debugEcho sql_getAllRows.format(if `distinct`: "distinct" else: "", tablename, limit, offset)
  this.db.getAllRows(sql(sql_getAllRows.format(if `distinct`: "distinct" else: "", tablename, limit, offset)))

func searchColumns*(this: Gatabase, tablename, columnname, value: string, limit=int.high, offset=0, `distinct`=false): auto =
  ## Get all Rows from table.
  when not defined(release): debugEcho sql_searchColumns.format(if `distinct`: "distinct" else: "", tablename, columnname, value, limit, offset)
  this.db.getAllRows(sql(sql_searchColumns.format(if `distinct`: "distinct" else: "", tablename, columnname, value, limit, offset)))

func deleteAllFromTable*(this: Gatabase, tablename: string, limit=int.high, offset=0): auto =
  ## Delete all from table.
  when not defined(release): debugEcho sql_deleteAll.format(tablename, limit, offset)
  this.db.tryExec(sql(sql_deleteAll.format(tablename, limit, offset)))

func deleteValueFromTable*(this: Gatabase, tablename, columnname, value: string, limit=int.high, offset=0): auto =
  ## Delete all from table.
  when not defined(release): debugEcho sql_deleteValue.format(tablename, columnname, value, limit, offset)
  this.db.tryExec(sql(sql_deleteValue.format(tablename, columnname, value, limit, offset)))

func dropTable*(this: Gatabase, tablename: string): auto =
  ## Drop a table if exists.
  when not defined(release): debugEcho sql_dropTable.format(tablename)
  this.db.tryExec(sql(sql_dropTable.format(tablename)))

func renameTable*(this: Gatabase, old_name, new_name: string): auto =
  ## Rename a table.
  assert old_name.strip.len > 1, "'old_name' must not be an empty string."
  assert new_name.strip.len > 1, "'new_name' must not be an empty string."
  when not defined(release): debugEcho sql_renameTable.format(old_name, new_name)
  this.db.tryExec(sql(sql_renameTable.format(old_name, new_name)))

func changeAutoVacuumTable*(this: Gatabase, tablename: string, enabled: bool): auto =
  ## Change the Auto-Vacuum setting for a table.
  assert tablename.strip.len > 0, "'tablename' must not be an empty string."
  when not defined(release): debugEcho sql_autoVacuum.format(tablename, enabled)
  this.db.tryExec(sql(sql_autoVacuum.format(tablename, enabled)))

func createTableUsers*(this: Gatabase, tablename="person", kind=""): auto =
  ## Create 1 Table Users if not exists,from 3 possible templates basic,medium or full.
  doAssert tablename.len > 2, "tablename must be a non-empty string"
  var cueri: SqlQuery
  if kind == "simple": cueri = sql(personTable_simple.format(tablename))
  elif kind == "full": cueri = sql(personTable_full.format(tablename))
  else:                cueri = sql(personTable_medium.format(tablename))
  when not defined(release): debugEcho cueri.repr
  this.db.tryExec(cueri)

proc backupDatabase*(this: Gatabase, dbname, filename: string, dataOnly=false, inserts=false): auto =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  assert dbname.strip.len > 1, "'dbname' must not be an empty string."
  assert filename.strip.len > 5, "'filename' must not be an empty string."
  when defined(sqlite):
    let cmd = fmt"{cmd_backup}{dbname.quoteShell} '.backup {filename.quoteShell}'"
  else:
    let
      a = if dataOnly: "--data-only " else: ""
      b = if inserts: "--inserts " else: ""
      c = fmt"--lock-wait-timeout={this.timeout.int * 2} "
      d = "--host=" & this.host & " --port=" & $this.port.int & " --username=" & this.user
      e = filename.quoteShell
      cmd = fmt"{cmd_backup}{a}{b}{c}{d} --file={e} --dbname={dbname}"
  when not defined(release): echo cmd
  execCmdEx(cmd)


when isMainModule:
  {.hint: "This is for Demo purposes only!.", passL: "-s", passC: "-flto" .}
  # Database init (change to your user and password).
  var database = Gatabase(user: "juan", password: "juan", host: "localhost",
                          dbname: "database", port: Port(5432), timeout: 10)
  database.connect()

  # Engine
  echo gatabaseVersion
  echo gatabaseIsPostgres
  echo gatabaseIsFields
  echo database.uri
  echo database.enableHstore()
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
  echo database.forceReloadConfig()
  echo database.isUserConnected(username = "juan")
  #echo database.getDatabaseSize(databasename = "database")
  #echo database.getTableSize(tablename = "mytable")

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

  when not defined(noFields):
    let   # Fields
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
                              "This is a Documentation Comment")
    #echo database.getAllRows("table_name", limit=255, offset=2, `distinct`=true)
    #echo database.searchColumns("table_name", "name0", $int8.high, 666)
    #echo database.changeAutoVacuumTable("table_name", true)
    #echo database.renameTable("table_name", "cats")
    #echo database.dropTable("cats")

  # Table Helpers (ready-made "Users" table from 3 templates to choose)
  echo database.createTableUsers(tablename="usuarios", kind="medium")
  echo database.dropTable("usuarios")

  # Backups
  echo database.backupDatabase("database", "backup0.sql")
  echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true)

  # Std Lib compatible
  echo database.db.getRow(sql"SELECT current_database(); /* Still compatible with Std Lib */")

  database.close()
