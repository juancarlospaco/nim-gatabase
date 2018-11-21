## - Encoding is UTF-8.
## - Database user must have a password.
## - Database connection is to hostname not unix socket.
## - Comments for Self-Documentation are supported on everything.
import db_postgres, strformat, strutils, osproc

const
  query_LoggedInUsers = sql"SELECT DISTINCT datname, usename, client_hostname, client_port, query FROM pg_stat_activity;"
  query_Version = sql"SHOW SERVER_VERSION;"
  query_Env = sql"SHOW ALL;"
  query_currentUser = sql"SELECT current_user;"
  query_allUsers = sql"SELECT rolname FROM pg_roles;"
  query_allDatabases = sql"SELECT datname FROM pg_database WHERE datistemplate = false;"
  query_allSchemas = sql"SELECT nspname FROM pg_catalog.pg_namespace;"
  query_allTables = sql"SELECT tablename FROM pg_catalog.pg_tables;"
  query_currentDatabase = sql"SELECT current_database();"
  pg_dump = "pg_dump --verbose --no-password --encoding=UTF8 "

type Gatabase* = object  ## Postgres database object type.
  user*, password*, host*, dbname*, uri*, encoding*: string
  timeout*: byte ## Database connection Timeout, byte type, 1 ~ 255.
  port: int16     ## Database port, int16 type, Postgres default is 5432.
  db*: DbConn   ## Database connection instance.

func connect*(this: var Gatabase) {.discardable.} =
  ## Open the Database connection, set Encoding to UTF-8, set URI.
  this.encoding = "UTF8"
  this.uri = fmt"postgresql://{this.user}:{this.password}@{this.host}:{this.port}/{this.dbname}?connect_timeout={this.timeout}"
  this.db = db_postgres.open(
    "", "", "",
    fmt"host={this.host} port={this.port} dbname={this.dbname} user={this.user} password={this.password} connect_timeout={this.timeout}")
  doAssert this.db.setEncoding(this.encoding), "Failed to set Encoding to UTF-8"

func close*(this: Gatabase) {.discardable, inline.} =
  ## Close the Database connection.
  this.db.close()

func getLoggedInUsers*(this: Gatabase): seq[Row] =
  ## Return all active logged-in users.
  this.db.getAllRows(query_LoggedInUsers)

template document(this: Gatabase, what, target, comment: string): untyped =
  ## Document target with comment. Postgres Comment is like Self-Documentation.
  assert what.strip.len > 1, "what must not be an empty string."
  assert target.strip.len > 1, "target must not an be empty string."
  if comment.strip.len > 0:
    discard this.db.tryExec(sql("COMMENT ON $1 $2 IS ?;".format(what, target)), comment.strip)

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

func createDatabase*(this: Gatabase, dbname, comment: string, owner=this.user): bool =
  ## Create a new database, with optional comment.
  result = this.db.tryExec(sql(fmt"CREATE DATABASE {dbname} WITH OWNER {owner};"))
  document(this, "DATABASE", dbname, comment)

func dropDatabase*(this: Gatabase, dbname: string): bool =
  ## Drop a database if exists.
  this.db.tryExec(sql(fmt"DROP DATABASE IF EXISTS {dbname};"))

func renameDatabase*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a database.
  this.db.tryExec(sql(fmt"ALTER DATABASE {old_name} RENAME TO {new_name};"))

func grantSelect*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant select privileges to a user on a database.
  this.db.tryExec(sql(fmt"GRANT SELECT ON {dbname} TO {user};"))

func grantAll*(this: Gatabase, dbname: string, user="PUBLIC"): bool =
  ## Grant all privileges to a user on a database.
  this.db.tryExec(sql(fmt"GRANT ALL PRIVILEGES ON DATABASE {dbname} TO {user};"))

func createUser*(this: Gatabase, user, password, comment: string): bool =
  ## Create a new user.
  result = this.db.tryExec(sql(fmt"CREATE USER {user} WITH PASSWORD ?;"), password)
  document(this, "USER", user, comment)

func changePasswordUser*(this: Gatabase, user, password: string): bool =
  ## Change the password of a user.
  this.db.tryExec(sql(fmt"ALTER ROLE {user} WITH PASSWORD ?;"), password)

func dropUser*(this: Gatabase, user: string): bool =
  ## Drop a user if exists.
  this.db.tryExec(sql(fmt"DROP USER IF EXISTS {user};"))

func renameUser*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a user.
  this.db.tryExec(sql(fmt"ALTER USER {old_name} RENAME TO {new_name};"))

func createSchema*(this: Gatabase, schemaname, comment: string): bool =
  ## Create a new schema.
  result = this.db.tryExec(sql(fmt"CREATE SCHEMA IF NOT EXISTS {schemaname};"))
  document(this, "SCHEMA", schemaname, comment)

func dropSchema*(this: Gatabase, schemaname: string): bool =
  ## Drop an schema if exists.
  this.db.tryExec(sql(fmt"DROP SCHEMA IF EXISTS {schemaname} CASCADE;"))

func dropTable*(this: Gatabase, tablename: string): bool =
  ## Drop a table if exists.
  this.db.tryExec(sql(fmt"DROP TABLE IF EXISTS {tablename} CASCADE;"))

func renameTable*(this: Gatabase, old_name, new_name: string): bool =
  ## Rename a table.
  this.db.tryExec(sql(fmt"ALTER TABLE {old_name} RENAME TO {new_name};"))

func changeAutoVacuumTable*(this: Gatabase, tablename: string, autovacuum_enabled: bool): bool =
  ## Change the Auto-Vacuum setting for a table.
  this.db.tryExec(sql(fmt"ALTER TABLE {tablename} SET (autovacuum_enabled = {autovacuum_enabled});"))

proc backupDatabase(this: Gatabase, dbname, filename: string, dataOnly=false,
                    inserts=false, comments=true): tuple[output: TaintedString, exitCode: int] =
  ## Backup the whole Database to a file with optional Compression.
  let
    a = if dataOnly: "--data-only " else: ""
    b = if inserts: "--inserts " else: ""
    c = if comments: "" else: "--no-comments "
    d = fmt"--lock-wait-timeout={this.timeout * 2} "
    e = "--host=" & this.host & " --port=" & $this.port & " --username=" & this.user
    cmd = fmt"{pg_dump}{a}{b}{c}{d}{e} --file={filename.quoteShell} --dbname={dbname}"
  echo cmd
  execCmdEx(cmd)


when isMainModule:
  var database = Gatabase(user: "juan", password: "juan", host: "localhost",
                          dbname: "database", port: 5432.int16, timeout: 10)
  database.connect()
  # Engine
  echo database.uri
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
  echo database.dropDatabase("testing2")
  # User
  echo database.createUser("pepe", "s3cr3t", "This is a Documentation Comment")
  echo database.changePasswordUser("pepe", "passw0rd")
  echo database.renameUser("pepe", "pepe2")
  echo database.dropUser("pepe2")
  # Schema
  echo database.createSchema("memes", "This is a Documentation Comment")
  echo database.dropSchema("memes")  # AFAIK Postgres Schemas cant be Renamed?.
  # Tables
  echo database.renameTable("dogs", "cats")
  echo database.dropTable("cats")
  echo database.changeAutoVacuumTable("sometable", true)
  # Backups
  echo database.backupDatabase("database", "backup0.sql").output
  echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true, comments=false).output

  database.close()
