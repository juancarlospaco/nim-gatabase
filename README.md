# Nim-Gatabase

![screenshot](https://source.unsplash.com/yMSecCHsIBc/800x600 "Postgres high-level ORM for Nim")


# API

- [Postgres >= 10.](https://www.postgresql.org)
- UTF-8 encoding.
- All SQL are `const`.
- Database user must have a password.
- Database connection is to hostname.
- Self-Documentation Comments supported.
- AutoVacuum for Tables supported.
- Backups for Databases supported.
- The `timeout` argument is on Seconds.
- No OS-specific code, so it should work on Linux, Windows and Mac.
- Compatible with `db_postgres` and Ormin.
- You can still use Ormin as normal.
- You can still use std lib `db_postgres` as normal.
- You can write with Gatabase and read with Ormin.
- Each Field has its own Metadata.
- Run the module itself for an Example.
- Run `nim doc gatabase.nim` for more Documentation.


# Fields

- `StringField`
- `Int8Field`
- `Int16Field`
- `Int32Field`
- `IntField`
- `Float32Field`
- `FloatField`
- `BoolField`
- `PDocumentField`
- `ColorField`
- `HashField`
- `HttpCodeField`
- `PortField`
- `PegField`


# Use

```nim
import gatabase

# Database init (change to your user and password).
var database = Gatabase(user: "MyUserHere", password: "Passw0rd!", host: "localhost",
                        dbname: "database", port: 5432, timeout: 42)
database.connect(debug=true)

# Engine
echo database.uri
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
echo database.renameUser("pepe", "BongoCat")
echo database.dropUser("BongoCat")

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
  # fails = newInt8Field(int64.high, "name9", "Input an int8", "Integer overflow error")
assert a is Field
assert b is Field

# Tables
echo database.createTable("table_name", fields = @[a, b, c, d, e, f, g],
                          "This is a Documentation Comment", debug=true)
echo database.getAllRows("table_name", limit=255)
echo database.searchColumns("table_name", "name0", $int8.high, 255)
echo database.changeAutoVacuumTable("table_name", true)
echo database.renameTable("table_name", "cats")
echo database.dropTable("cats")

# Backups
echo database.backupDatabase("database", "backup0.sql").output
echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true, debug=true).output

# db_postgres compatible
echo database.db.getRow(sql"SELECT current_database(); /* Still compatible with Std Lib */")

database.close()

# Check the Docs for more...
```


# FAQ

- Supports SQLite ?.

No.

- This is faster than [ORMin](https://github.com/Araq/ormin) ?.

No.

- I dont want to pass the Table name every time I use a function ?.

https://nim-lang.org/docs/manual.html#statements-and-expressions-using-statement


# Requisites

- None.
