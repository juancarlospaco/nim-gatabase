# Nim-Gatabase

![screenshot](https://source.unsplash.com/yMSecCHsIBc/800x600 "Postgres high-level ORM for Nim")


# API

- [Postgres >= 10.](https://www.postgresql.org)
- UTF-8 encoding.
- Database user must have a password.
- Database connection is to hostname.
- Self-Documentation Comments supported.
- AutoVacuum for Tables supported.
- Backups for Databases supported.
- The `timeout` argument is on Seconds.
- No OS-specific code, so it should work on Linux, Windows and Mac.
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
echo database.getTop(3)
echo database.dropDatabase("testing2")

# User
echo database.createUser("pepe", "PaSsW0rD!", "This is a Documentation Comment")
echo database.changePasswordUser("pepe", "p@ssw0rd")
echo database.renameUser("pepe", "BongoCat")
echo database.dropUser("BongoCat")

# Schema
echo database.createSchema("memes", "This is a Documentation Comment", autocommit=false)
echo database.dropSchema("memes")

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
echo database.backupDatabase("database", "backup0.sql").output
echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true, debug=true).output

database.close()

# Check the Docs for more...
```


# FAQ

- Supports SQLite ?.

No.

- This is faster than [ORMin](https://github.com/Araq/ormin) ?.

No.


# Requisites

- None.
