# Gatabase

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/gatabase.png "Compile-Time ORM for Nim")

![](https://img.shields.io/github/languages/count/juancarlospaco/nim-gatabase?logoColor=green&style=for-the-badge)
![](https://img.shields.io/github/languages/top/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/stars/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/maintenance/yes/2020?style=for-the-badge)
![](https://img.shields.io/github/languages/code-size/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/issues-raw/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/issues-pr-raw/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/last-commit/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/liberapay/patrons/juancarlospaco?style=for-the-badge)
![](https://img.shields.io/twitch/status/juancarlospaco?style=for-the-badge)
![](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fjuancarlospaco%2Fnim-gatabase)

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg "Compile-Time ORM for Nim")


# Use

- Gatabase is designed as 1 simplified [Strong Static Typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking) [Compile-Time](https://wikipedia.org/wiki/Compile_time) [SQL](https://wikipedia.org/wiki/SQL) [DSL](https://wikipedia.org/wiki/Domain-specific_language) [Sugar](https://en.wikipedia.org/wiki/Syntactic_sugar). Nim mimics SQL. ~1000 LoC.
- Gatabase syntax is almost the same as SQL syntax, [no new ORM to learn ever again](https://pgexercises.com/questions/basic/selectall.html), any [SQL WYSIWYG is your GUI](https://pgmodeler.io/screenshots).
- You can literally [Copy&Paste a SQL query from StackOverflow](https://stackoverflow.com/questions/tagged/postgresql?tab=Frequent) to Gatabase and with few tiny syntax tweaks is running.
- SQL is Minified when build for Release, Pretty-Printed when build for Debug. It can be assigned to `let` and `const`.


### Support

- All SQL standard syntax is supported.
- ✅ `--` Human readable comments, multi-line comments produce multi-line SQL comments, requires [Stropping](https://en.wikipedia.org/wiki/Stropping_(syntax)#Modern_use).
- ✅ `COMMENT`, Postgres-only.
- ✅ `UNION`, `UNION ALL`.
- ✅ `INTERSECT`, `INTERSECT ALL`.
- ✅ `EXCEPT`, `EXCEPT ALL`, requires [Stropping](https://en.wikipedia.org/wiki/Stropping_(syntax)#Modern_use).
- ✅ `CASE` with multiple `WHEN` and 1 `ELSE` with correct indentation, requires [Stropping](https://en.wikipedia.org/wiki/Stropping_(syntax)#Modern_use).
- ✅ `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`.
- ✅ `OFFSET`.
- ✅ `LIMIT`.
- ✅ `FROM`, requires [Stropping](https://en.wikipedia.org/wiki/Stropping_(syntax)#Modern_use).
- ✅ `WHERE`, `WHERE NOT`, `WHERE EXISTS`, `WHERE NOT EXISTS`.
- ✅ `ORDER BY`.
- ✅ `SELECT`, `SELECT *`, `SELECT DISTINCT`.
- ✅ `SELECT TOP`, `SELECT MIN`, `SELECT MAX`, `SELECT AVG`, `SELECT SUM`, `SELECT COUNT`.
- ✅ `SELECT trim(lower( ))` for strings, `SELECT round( )` for floats, useful shortcuts.
- ✅ `DELETE FROM`.
- ✅ `LIKE`, `NOT LIKE`.
- ✅ `BETWEEN`, `NOT BETWEEN`.
- ✅ `HAVING`.
- ✅ `INSERT INTO`.
- ✅ `IS NULL`, `IS NOT NULL`.
- ✅ `UPDATE`, `SET`.
- ✅ `VALUES`.

Not supported:
- Deep nested SubQueries are not supported, because KISS.
- `TRUNCATE`, because is the same as `DELETE FROM` without a `WHERE`.
- `WHERE IN`, `WHERE NOT IN`, because is the same as `JOIN`, but `JOIN` is a lot faster.
- `DROP TABLE` is left to the user.


## API Equivalents

 Nim StdLib API    | Gatabase ORM API
-------------------|------------------
`tryExec`          | [`tryExec`](https://juancarlospaco.github.io/nim-gatabase/#tryExec.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`exec`             | [`exec`](https://juancarlospaco.github.io/nim-gatabase/#exec.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`getRow`           | [`getRow`](https://juancarlospaco.github.io/nim-gatabase/#getRow.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`getAllRows`       | [`getAllRows`](https://juancarlospaco.github.io/nim-gatabase/#getAllRows.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`getValue`         | [`getValue`](https://juancarlospaco.github.io/nim-gatabase/#getValue.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`tryInsertID`      | [`tryInsertID`](https://juancarlospaco.github.io/nim-gatabase/#tryInsertID.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`insertID`         | [`insertID`](https://juancarlospaco.github.io/nim-gatabase/#insertID.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`execAffectedRows` | [`execAffectedRows`](https://juancarlospaco.github.io/nim-gatabase/#execAffectedRows.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)


# Install

- [`nimble install gatabase`](https://nimble.directory/pkg/gatabase "nimble install gatabase 👑 https://nimble.directory/pkg/gatabase")


### Comments

```sql
-- SQL Comments are supported, but stripped when build for Release. This is SQL.
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
`--` "SQL Comments are supported, but stripped when build for Release. This is Nim."
```


### SELECT & FROM

```sql
SELECT *
FROM sometable
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
select '*'
`from` "sometable"
```

---

```sql
SELECT somecolumn
FROM sometable
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
select "somecolumn"
`from` "sometable"
```

---

```sql
SELECT DISTINCT somecolumn
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectdistinct "somecolumn"
```


### MIN & MAX

```sql
SELECT MIN(somecolumn)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectmin "somecolumn"
```

---

```sql
SELECT MAX(somecolumn)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectmax "somecolumn"
```


### COUNT & AVG & SUM

```sql
SELECT COUNT(somecolumn)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectcount "somecolumn"
```

---

```sql
SELECT AVG(somecolumn)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectavg "somecolumn"
```

---

```sql
SELECT SUM(somecolumn)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectsum "somecolumn"
```


### TRIM & LOWER

```sql
SELECT trim(lower(somestringcolumn))
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selecttrim "somestringcolumn"
```


### ROUND

```sql
SELECT round(somefloatcolumn, 2)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectround2 "somefloatcolumn"
```

---

```sql
SELECT round(somefloatcolumn, 4)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectround4 "somefloatcolumn"
```

---

```sql
SELECT round(somefloatcolumn, 6)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selectround6 "somefloatcolumn"
```


### TOP

```sql
SELECT TOP 5 *
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
selecttop 5
```


### WHERE

```sql
SELECT somecolumn
FROM sometable
WHERE power > 9000
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
select "somecolumn"
`from` "sometable"
where "power > 9000"
```


### LIMIT & OFFSET

```sql
OFFSET 9
LIMIT 42
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
offset 9
limit 42
```


### INSERT

```sql
INSERT INTO person
VALUES (42, 'Nikola Tesla', true, 'nikola.tesla@nim-lang.org', 9.6)
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
insertinto "person"
values 5
```

**Example:**
```nim
insertinto "person"
values 5
```
 ⬆️ Nim ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Generated SQL ⬇️
```sql
INSERT INTO person
VALUES ( ?, ?, ?, ?, ? )
```

* The actual values are passed via `varargs` directly using stdlib, Gatabase does not format values ever.
* Nim code `values 5` generates `VALUES ( ?, ?, ?, ?, ? )`.


### UPDATE

```sql
UPDATE person
SET name = 'Nikola Tesla', mail = 'nikola.tesla@nim-lang.org'
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
update "person"
set ["name", "mail"]
```

**Example:**
```nim
update "person"
set ["name", "mail"]
```
 ⬆️ Nim ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Generated SQL ⬇️
```sql
UPDATE person
SET name = ?, mail = ?
```

* The actual values are passed via `varargs` directly using stdlib, Gatabase does not format values ever.
* Nim code `set ["key", "other", "another"]` generates `SET key = ?, other = ?, another = ?`.


### DELETE

```sql
DELETE debts
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
delete "debts"
```


### ORDER BY

```sql
ORDER BY ASC
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
orderby Asc
```

---

```sql
ORDER BY DESC
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
orderby Desc
```


### CASE

```sql
CASE
  WHEN foo > 10 THEN 9
  WHEN bar < 42 THEN 5
  ELSE 0
END
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
`case` {
  "foo > 10": "9",
  "bar < 42": "5",
  "else":     "0"
}
```


### COMMENT

```sql
COMMENT ON TABLE myTable IS 'This is an SQL COMMENT on a TABLE'
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
commentontable {"myTable": "This is an SQL COMMENT on a TABLE"}
```

---

```sql
COMMENT ON COLUMN myColumn IS 'This is an SQL COMMENT on a COLUMN'
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
commentoncolumn {"myColumn": "This is an SQL COMMENT on a COLUMN"}
```

---

```sql
COMMENT ON DATABASE myDatabase IS 'This is an SQL COMMENT on a DATABASE'
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
commentondatabase {"myDatabase": "This is an SQL COMMENT on a DATABASE"}
```


### GROUP BY

```sql
GROUP BY country
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
groupby "country"
```


### JOIN

```sql
FULL JOIN tablename
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
fulljoin "tablename"
```

---

```sql
INNER JOIN tablename
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
innerjoin "tablename"
```

---

```sql
LEFT JOIN tablename
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
leftjoin "tablename"
```

---

```sql
RIGHT JOIN tablename
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
rightjoin "tablename"
```


### HAVING

```sql
HAVING beer > 5
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
having "beer > 5"
```


### UNION

```sql
UNION ALL
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
union true
```

---

```sql
UNION
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
union false
```


### INTERSECT

```sql
INTERSECT ALL
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
intersect true
```

---

```sql
INTERSECT
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
intersect false
```


### EXCEPT

```sql
EXCEPT ALL
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
`except` true
```

---

```sql
EXCEPT
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
`except` false
```


### IS NULL

```sql
IS NULL
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
isnull true
```

---

```sql
IS NOT NULL
```
 ⬆️ SQL ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim ⬇️
```nim
isnull false
```


### Wildcards

- Nim `'*'` ➡️ SQL `*`.
- Nim `'?'` ➡️ SQL `?`.


# Anti-Obfuscation

Gatabase wont like Obfuscation, its code is easy to read and similar to Pretty-Printed SQL. [`nimpretty` friendly](https://nim-lang.github.io/Nim/tools.html). Very [KISS](https://en.wikipedia.org/wiki/KISS_principle).

**Compiles Ok:**
```nim
let variable = query Sql:
  select  '*'
  `from`  "clients"
  groupby "country"
  orderby AscNullsLast
```

**Fails to Compile:**

- `let variable = query Sql: select('*') from("clients") groupby("country") orderby(AscNullsLast)`
- `let variable = query Sql: '*'.select() "clients".from() "country".groupby() AscNullsLast.orderby()`
- `let variable = query Sql: select '*' from "clients" groupby "country" orderby AscNullsLast`
- `let variable = query Sql:select'*' from"clients" groupby"country" orderby AscNullsLast`

*This helps on big projects where each developer tries to use a different code style.*


# Your data, your way

Nim has `template` is like a literal copy&paste of code in-place with no performance cost,
that allows you to create your own custom ORM function callbacks on-the-fly,
like the ones used on scripting languages.

```nim
template getMemes(): string =
  result = query getValue:
    select "url"
    `from` "memes"
    limit 1
```

Then you do `getMemes()` when you need it❕. The API that fits your ideas.

From this `MyClass.meta.Session.query(Memes).all().filter().first()` to this `getMemes()`.


# For Python Devs

Remember on Python2 you had like `print "value"`?, on Nim you can do the same for any function,
then we made functions to mimic basic standard SQL, like `select "value"` and it worked,
its Type-Safe and valid Nim code, you have an ORM that gives you the freedom and power,
this allows to support interesting features, like `CASE`, `UNION`, `INTERSECT`, `COMMENT`, etc.

When you get used to `template` it requires a lot less code to do the same than SQLAlchemy.


```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy import Column, Integer, String, Boolean, Float

engine = create_engine("sqlite:///:memory:", echo=False)
engine.execute("""
  create table if not exists person(
    id      integer     primary key,
    name    varchar(9)  not null unique,
    active  bool        not null default true,
    rank    float       not null default 0.0
  ); """
)


meta = MetaData()
persons = Table(
  "person", meta,
  Column("id", Integer, primary_key = True),
  Column("name", String, nullable = False, unique = True),
  Column("active", Boolean, nullable = False, default = True),
  Column("rank", Float, nullable = False, default = 0.0),
)


conn = engine.connect()


ins = persons.insert()
ins = persons.insert().values(id = 42, name = "Pepe", active = True, rank = 9.6)
result = conn.execute(ins)


persons_query = persons.select()
result = conn.execute(persons_query)
row = result.fetchone()

print(row)

```
 ⬆️ CPython 3 + SQLAlchemy ⬆️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⬇️ Nim 1.0 + Gatabase ⬇️
```nim
import db_sqlite, gatabase

let db = open(":memory:", "", "", "")
db.exec(sql"""
  create table if not exists person(
    id      integer     primary key,
    name    varchar(9)  not null unique,
    active  bool        not null default true,
    rank    float       not null default 0.0
  ); """)


query Exec:
  insertinto "person"
  values (42, "Pepe", true, 9.6)


let row = query GetRow:
  select '*'
  `from` "person"

echo row
```


# Smart SQL Checking

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/sql_checking.png "Smart SQL Checking")

It will perform a SQL Syntax checking at compile-time. Examples here Fail **intentionally** as expected:

```nim
query Exec:
  where "failure"
```

Fails to compile as expected, with a friendly error:
```
gatabase.nim(48, 16) Warning: WHERE without SELECT nor INSERT nor UPDATE nor DELETE.
```

Typical error of making a `DELETE FROM` without `WHERE` that deletes all your data:
```nim
query Exec:
  delete "users"
```

Compiles but prints a friendly warning:
```
gatabase.nim(207, 57) Warning: DELETE FROM without WHERE.
```

Typical [bad practice of using `SELECT *` everywhere](https://stackoverflow.com/a/3639964):
```nim
query Exec:
  select '*'
```

Compiles but prints a friendly warning:
```
gatabase.nim(20, 50) Warning: SELECT * is bad practice.
```

Non-SQL wont compile, even if its valid Nim:
```nim
query Sql:
  discard

query Sql:
  echo "This is not SQL, wont compile"
```


# Output

 Output    | Gatabase ORM API
-----------|------------------
`bool`     | [`tryExec`](https://juancarlospaco.github.io/nim-gatabase/#tryExec.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`Row`      | [`getRow`](https://juancarlospaco.github.io/nim-gatabase/#getRow.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`seq[Row]` | [`getAllRows`](https://juancarlospaco.github.io/nim-gatabase/#getAllRows.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`int64`    | [`tryInsertID`](https://juancarlospaco.github.io/nim-gatabase/#tryInsertID.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`int64`    | [`insertID`](https://juancarlospaco.github.io/nim-gatabase/#insertID.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`int64`    | [`execAffectedRows`](https://juancarlospaco.github.io/nim-gatabase/#execAffectedRows.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
`any`      | [`getValue`](https://juancarlospaco.github.io/nim-gatabase/#getValue.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)
           | [`exec`](https://juancarlospaco.github.io/nim-gatabase/#exec.t%2Cvarargs%5Bstring%2C%5D%2Cuntyped)

- [Gatabase Sugar can return very specific concrete types.](https://juancarlospaco.github.io/nim-gatabase/sugar.html#18)


### Tests

```console
$ nimble test

[Suite] Gatabase ORM Tests
  [OK] let   INSERT INTO
  [OK] let   SELECT ... FROM ... WHERE
  [OK] let   SELECT ... (comment) ... FROM ... COMMENT
  [OK] let   SELECT ... FROM ... LIMIT ... OFFSET
  [OK] let   INSERT INTO
  [OK] let   UNION ALL ... ORBER BY ... IS NOT NULL
  [OK] let   SELECT DISTINCT ... FROM ... WHERE
  [OK] let INSERT INTO
  [OK] const SELECT ... FROM ... WHERE
  [OK] const SELECT ... (comment) ... FROM ... COMMENT
  [OK] const SELECT ... FROM ... LIMIT ... OFFSET
  [OK] const INSERT INTO
  [OK] const UNION ALL ... ORBER BY ... IS NOT NULL
  [OK] const INTERSECT ALL
  [OK] const EXCEPT ALL
  [OK] const SELECT DISTINCT ... FROM ... WHERE
  [OK] var   CASE
  [OK] var   SELECT MAX .. WHERE EXISTS ... OFFSET ... LIMIT ... ORDER BY
  [OK] SELECT TRIM
  [OK] SELECT ROUND
  [OK] var   DELETE FROM WHERE
```

- Tests use a real database SQLite on RAM `":memory:"` with a `"person"` table. +20 Tests.
- [CI uses GitHub Actions CI.](https://github.com/juancarlospaco/nim-gatabase/actions)


# Requisites

- **None.**


## Stars

![Stars over time](https://starchart.cc/juancarlospaco/nim-gatabase.svg)


# FAQ

<details>

- This is not an ORM ?.

[Wikipedia defines ORM](https://en.wikipedia.org/wiki/Object-relational_mapping) as:

> Object-relational mapping in computer science is a programming technique for converting
> data between incompatible type systems using object-oriented programming languages.

Feel free to contribute to Wikipedia.

- Supports SQLite ?.

Yes.

- Supports MySQL ?.

No.

- Will support MySQL someday ?.

No.

- Supports Mongo ?.

No.

- Will support Mongo someday ?.

No.

- How is Parameter substitution done ?.

It does NOT make Parameter substitution internally, its delegated to standard library.

- This works with Synchronous code ?.

Yes.

- This works with Asynchronous code ?.

Yes.

- SQLite mode dont support some stuff ?.

We try to keep as similar as possible, but SQLite is very limited.

- Why not use JSON Type instead of Tuple and Table for arguments ?.

JSON wont work at compile time.

</details>


[  ⬆️  ⬆️  ⬆️  ⬆️  ](#Gatabase "Go to top")
