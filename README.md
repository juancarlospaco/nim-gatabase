# Nim-Gatabase

![screenshot](https://source.unsplash.com/yMSecCHsIBc/800x600 "Postgres high-level ORM for Nim")


# API

- [Postgres >= 10.](https://www.postgresql.org)
- UTF-8 encoding.
- [All SQL are `const`.](https://nim-lang.org/docs/manual.html#statements-and-expressions-const-section)
- Database user must have a password.
- Database connection is to hostname.
- [Self-Documentation Comments supported.](https://www.postgresql.org/docs/11/sql-comment.html)
- [Configurable AutoVacuum supported.](https://www.postgresql.org/docs/11/runtime-config-autovacuum.html)
- Backups for Databases supported.
- The `timeout` argument is on Seconds.
- `DISTINCT` supported on SQL, `bool` type, `false` by default.
- `LIMIT` supported on SQL, `int` type, `int.high` by default.
- `OFFSET` supported on SQL, `int` type, `0` by default.
- No OS-specific code, so it should work on Linux, Windows and Mac.
- This ORM can run on the Browser _(since you can not run Postgres on the Browser, it returns the Raw SQL Query instead of executing it)_
- Compatible with [`db_postgres`](https://nim-lang.org/docs/db_postgres.html) and [Ormin](https://github.com/Araq/ormin).
- You can still use std lib `db_postgres` as normal (same connection).
- You can write with Gatabase and read with Ormin.
- [Functional, all functions are `func` (Effects free).](https://nim-lang.org/docs/manual.html#procedures-func)
- Debug raw SQL when not build for Release.
- Single file. 0 Dependency. Self-Documented.
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
- `PegField`


# Use

```nim
import gatabase

# Database init (change to your user and password).
var database = Gatabase(user: "MyUserHere", password: "Passw0rd!", host: "localhost",
                        dbname: "database", port: 5432, timeout: 42)
database.connect()

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
                          "This is a Documentation Comment")
echo database.getAllRows("table_name", limit=255, offset=2, `distinct`=true)
echo database.searchColumns("table_name", "name0", $int8.high, 255)
echo database.changeAutoVacuumTable("table_name", true)
echo database.renameTable("table_name", "cats")
echo database.dropTable("cats")

# Backups
echo database.backupDatabase("database", "backup0.sql").output
echo database.backupDatabase("database", "backup1.sql", dataOnly=true, inserts=true).output

# db_postgres compatible (Raw Queries)
echo database.db.getRow(sql"SELECT current_database(); /* Still compatible with Std Lib */")

database.close()

# Check the Docs for more...
```

**Creating a Table with Fields:**

```nim
echo database.createTable(tablename="table_name", fields = @[a, b, c, d, e, f, g], comment="This is a Documentation Comment", autocommit=true)
```

**Produces the SQL:**

```sql
CREATE TABLE IF NOT EXISTS table_name(
  id SERIAL PRIMARY KEY,
  name0 smallint DEFAULT 127,
  name1 smallint DEFAULT 32767,
  name2 integer DEFAULT 2147483647,
  name3 bigint DEFAULT 9223372036854775807,
  name4 decimal DEFAULT 42.0,
  name5 decimal DEFAULT 666.0,
  name6 boolean DEFAULT true
); /* This is a Documentation Comment */

COMMENT ON TABLE table_name IS 'This is a Documentation Comment';
```


# Install

- `nimble install gatabase`


# FAQ

- Supports SQLite ?.

No.

- This is faster than [ORMin](https://github.com/Araq/ormin) ?.

No.

- I dont want to pass the Table name every time I use a function ?.

https://nim-lang.org/docs/manual.html#statements-and-expressions-using-statement


# Requisites

- None.

_(You need a working Postgres server up & running to use it, but not to install it)_


#### Alternatives

- [For a faster but lower-level ORM see ORMin.](https://github.com/Araq/blog/blob/master/ormin.rst#ormin)
(DSL ORM, Raw SQL Performance, can expose your database fields via JSON WebSockets automagically)
