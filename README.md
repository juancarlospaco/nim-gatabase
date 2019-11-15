# Gatabase

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/gatabase.png "Compile-Time ORM for Nim")

![](https://img.shields.io/github/languages/count/juancarlospaco/nim-gatabase?logoColor=green&style=for-the-badge)
![](https://img.shields.io/github/languages/top/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/stars/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/maintenance/yes/2019?style=for-the-badge)
![](https://img.shields.io/github/languages/code-size/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/issues-raw/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/issues-pr-raw/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/commit-activity/y/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/github/last-commit/juancarlospaco/nim-gatabase?style=for-the-badge)
![](https://img.shields.io/liberapay/patrons/juancarlospaco?style=for-the-badge)
![](https://img.shields.io/twitch/status/juancarlospaco?style=for-the-badge)
![](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fjuancarlospaco%2Fnim-gatabase)

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg "Compile-Time ORM for Nim")


# Use

- Gatabase is designed as 1 simplified [Strong Static Typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking) [Compile-Time](https://wikipedia.org/wiki/Compile_time) [SQL](https://wikipedia.org/wiki/SQL) [DSL](https://wikipedia.org/wiki/Domain-specific_language) [Sugar](https://en.wikipedia.org/wiki/Syntactic_sugar). Nim mimics SQL. ~1000 LoC.
- Gatabase syntax is almost the same as SQL syntax, [no new ORM to learn ever again](https://pgexercises.com/questions/basic/selectall.html), any [SQL WYSIWYG is your GUI](https://pgmodeler.io/screenshots).
- You can literally [copy&paste a SQL query from StackOverflow](https://stackoverflow.com/questions/tagged/postgresql?tab=Frequent) to Gatabase and with few tiny syntax tweaks is running.
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


Not supported:
- Deep nested SubQueries are not supported, because KISS.
- `TRUNCATE`, because is the same as `DELETE FROM` without a `WHERE`.
- `WHERE IN`, `WHERE NOT IN`, because is the same as `JOIN`, but `JOIN` is a lot faster.
- `CREATE TABLE` and `DROP TABLE`, is left to the user.
- [`UPDATE`](https://github.com/juancarlospaco/nim-gatabase/issues/2#issue-506354934).


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
values (42, "Nikola Tesla", true, "nikola.tesla@nim-lang.org", 9.6)
```


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
- No other `char` is needed.


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

ORM Output is choosed from `GatabaseOutput` [`enum` type](https://nim-lang.github.io/Nim/manual.html#types-enumeration-types), MetaProgramming generates different output code. Examples:

- `query Func:` generates 1 [anonymous inlined function](https://nim-lang.github.io/Nim/manual.html#procedures-anonymous-procs) `( func (): SqlQuery = ... )`.
- `query Prepared:` generates 1 Postgres Stored Procedure of [`SqlPrepared` type](https://nim-lang.github.io/Nim/db_postgres.html#parameter-substitution).
- `query TryExec:` generates code for 1 [`tryExec()` function](https://nim-lang.github.io/Nim/db_postgres.html#tryExec%2CDbConn%2CSqlQuery%2Cvarargs%5Bstring%2C%5D), etc etc etc.
- Compile using `-d:dev` for Debugging of the generated SQL.

See `nim doc gatabase.nim`, `runnableExamples`, [examples folder](https://github.com/juancarlospaco/nim-gatabase/tree/master/examples), [tests folder](https://github.com/juancarlospaco/nim-gatabase/tree/master/tests), [Std Lib db_postgres](https://nim-lang.github.io/Nim/db_postgres.html) for more documentation.


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


# Requisites

- **None.** _(You need a working Postgres server up & running to use it, but not to install it)_


## Stars

![Stars over time](https://starchart.cc/juancarlospaco/nim-gatabase.svg)


#### Contributors

- https://github.com/juancarlospaco/nim-gatabase/graphs/contributors

<svg width="355" height="130" class="capped-card-content"><g transform="translate(20,10)"><g class="x axis" transform="translate(0, 70)" fill="none" font-size="10" font-family="sans-serif" text-anchor="middle" data-darkreader-inline-fill="" style="--darkreader-inline-fill:none;"><path class="domain" stroke="#000" d="M0.5,6V0.5H315.5V6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#e8e6e3;"></path><g class="tick" opacity="1" transform="translate(11.92092541436464,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: block; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">December</text></g><g class="tick" opacity="1" transform="translate(38.8960635359116,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">2019</text></g><g class="tick" opacity="1" transform="translate(65.87120165745856,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">February</text></g><g class="tick" opacity="1" transform="translate(90.23584254143647,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: block; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">March</text></g><g class="tick" opacity="1" transform="translate(117.21098066298343,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">April</text></g><g class="tick" opacity="1" transform="translate(143.31595303867402,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">May</text></g><g class="tick" opacity="1" transform="translate(170.291091160221,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: block; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">June</text></g><g class="tick" opacity="1" transform="translate(196.3960635359116,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">July</text></g><g class="tick" opacity="1" transform="translate(223.37120165745858,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">August</text></g><g class="tick" opacity="1" transform="translate(250.34633977900552,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: block; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">September</text></g><g class="tick" opacity="1" transform="translate(276.45131215469615,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">October</text></g><g class="tick" opacity="1" transform="translate(303.4264502762431,0)"><line stroke="#000" y2="6" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" y="9" dy="0.71em" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">November</text></g></g><g class="y axis" fill="none" font-size="10" font-family="sans-serif" text-anchor="end" data-darkreader-inline-fill="" style="--darkreader-inline-fill:none;"><path class="domain" stroke="#000" d="M315,70.5H0.5V0.5H315" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#e8e6e3;"></path><g class="tick" opacity="1" transform="translate(0,70.5)"><line stroke="#000" x2="315" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" x="-10" dy="0.32em" dx="157.5" class="midlabel" style="display: none; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">0</text></g><g class="tick" opacity="1" transform="translate(0,22.88095238095238)"><line stroke="#000" x2="315" data-darkreader-inline-stroke="" style="--darkreader-inline-stroke:#666666;"></line><text fill="#6a737d" x="-10" dy="0.32em" dx="157.5" class="midlabel" style="display: block; --darkreader-inline-fill:#bdb8ae;" data-darkreader-inline-fill="">200</text></g></g><path d="M0,58.333333333333336L1.0151933701657458,58.333333333333336C2.0303867403314917,58.333333333333336,4.060773480662983,58.333333333333336,6.091160220994475,60.07936507936508C8.121546961325967,61.82539682539683,10.151933701657457,65.31746031746032,12.18232044198895,67.26190476190476C14.212707182320441,69.2063492063492,16.243093922651934,69.6031746031746,18.273480662983424,69.8015873015873C20.303867403314914,70,22.334254143646405,70,24.3646408839779,70C26.395027624309392,70,28.425414364640886,70,30.45580110497237,70C32.48618784530387,70,34.51657458563536,70,36.54696132596685,70C38.577348066298335,70,40.60773480662983,70,42.63812154696132,70C44.66850828729281,70,46.6988950276243,70,48.7292817679558,67.53968253968254C50.75966850828729,65.07936507936508,52.790055248618785,60.15873015873016,54.82044198895028,60.15873015873016C56.85082872928177,60.15873015873016,58.88121546961327,65.07936507936508,60.91160220994476,67.5C62.94198895027625,69.92063492063492,64.97237569060773,69.84126984126983,67.00276243093923,69.84126984126983C69.03314917127072,69.84126984126983,71.06353591160222,69.92063492063492,73.09392265193371,69.96031746031746C75.1243093922652,70,77.1546961325967,70,79.18508287292819,69.96031746031746C81.21546961325969,69.92063492063492,83.24585635359115,69.84126984126983,85.27624309392264,69.84126984126983C87.30662983425414,69.84126984126983,89.33701657458563,69.92063492063492,91.36740331491713,69.96031746031746C93.3977900552486,70,95.4281767955801,70,97.4585635359116,70C99.48895027624309,70,101.51933701657458,70,103.54972375690608,70C105.58011049723757,70,107.61049723756906,70,109.64088397790056,70C111.67127071823205,70,113.70165745856355,70,115.73204419889504,70C117.76243093922652,70,119.79281767955801,70,121.8232044198895,70C123.853591160221,70,125.8839779005525,70,127.91436464088399,70C129.94475138121547,70,131.97513812154696,70,134.00552486187846,70C136.03591160220995,70,138.06629834254144,70,140.0966850828729,70C142.1270718232044,70,144.1574585635359,70,146.1878453038674,70C148.21823204419888,70,150.24861878453038,70,152.27900552486187,70C154.3093922651934,70,156.3397790055249,70,158.37016574585638,70C160.40055248618788,70,162.43093922651937,70,164.46132596685084,70C166.4917127071823,70,168.5220994475138,70,170.5524861878453,70C172.58287292817678,70,174.61325966850828,70,176.64364640883977,70C178.67403314917127,70,180.70441988950276,70,182.73480662983425,70C184.76519337016575,70,186.7955801104972,70,188.82596685082868,70C190.8563535911602,70,192.88674033149172,70,194.9171270718232,70C196.94751381215465,70,198.97790055248618,70,201.0082872928177,70C203.03867403314916,70,205.06906077348063,70,207.09944751381215,70C209.12983425414367,70,211.16022099447514,70,213.1906077348066,70C215.22099447513813,70,217.25138121546965,70,219.28176795580112,70C221.31215469613258,70,223.34254143646407,70,225.37292817679554,70C227.40331491712706,70,229.43370165745856,70,231.46408839779008,70C233.49447513812154,70,235.52486187845304,70,237.55524861878453,70C239.58563535911603,70,241.61602209944752,70,243.646408839779,70C245.6767955801105,70,247.707182320442,70,249.73756906077347,70C251.767955801105,70,253.79834254143648,70,255.82872928176798,70C257.85911602209944,70,259.88950276243094,70,261.91988950276243,70C263.9502762430939,70,265.9806629834254,70,268.0110497237569,70C270.0414364640884,70,272.0718232044199,70,274.1022099447514,58.333333333333336C276.1325966850829,46.666666666666664,278.1629834254143,23.333333333333332,280.1933701657458,22.222222222222225C282.2237569060773,21.11111111111111,284.2541436464088,42.22222222222222,286.2845303867403,53.88888888888889C288.3149171270718,65.55555555555556,290.3453038674033,67.77777777777779,292.3756906077348,68.88888888888889C294.4060773480663,70,296.43646408839777,70,298.46685082872926,70C300.49723756906076,70,302.52762430939225,70,304.55801104972375,69.88095238095238C306.58839779005524,69.76190476190476,308.61878453038673,69.52380952380953,309.63397790055245,69.40476190476191L310.6491712707182,69.28571428571429L310.6491712707182,70L309.63397790055245,70C308.61878453038673,70,306.58839779005524,70,304.55801104972375,70C302.52762430939225,70,300.49723756906076,70,298.46685082872926,70C296.43646408839777,70,294.4060773480663,70,292.3756906077348,70C290.3453038674033,70,288.3149171270718,70,286.2845303867403,70C284.2541436464088,70,282.2237569060773,70,280.1933701657458,70C278.1629834254143,70,276.1325966850829,70,274.1022099447514,70C272.0718232044199,70,270.0414364640884,70,268.0110497237569,70C265.9806629834254,70,263.9502762430939,70,261.91988950276243,70C259.88950276243094,70,257.85911602209944,70,255.82872928176798,70C253.79834254143648,70,251.767955801105,70,249.7375690607735,70C247.707182320442,70,245.6767955801105,70,243.64640883977904,70C241.61602209944752,70,239.58563535911603,70,237.5552486187845,70C235.52486187845304,70,233.49447513812154,70,231.46408839779005,70C229.43370165745856,70,227.40331491712706,70,225.37292817679557,70C223.34254143646407,70,221.31215469613258,70,219.28176795580112,70C217.25138121546965,70,215.22099447513813,70,213.1906077348066,70C211.16022099447514,70,209.12983425414367,70,207.09944751381215,70C205.06906077348063,70,203.03867403314916,70,201.0082872928177,70C198.97790055248618,70,196.94751381215465,70,194.9171270718232,70C192.88674033149172,70,190.8563535911602,70,188.82596685082873,70C186.7955801104972,70,184.76519337016575,70,182.73480662983422,70C180.70441988950276,70,178.67403314917127,70,176.64364640883977,70C174.61325966850828,70,172.58287292817678,70,170.5524861878453,70C168.5220994475138,70,166.4917127071823,70,164.46132596685084,70C162.43093922651937,70,160.40055248618788,70,158.37016574585638,70C156.3397790055249,70,154.3093922651934,70,152.27900552486187,70C150.24861878453038,70,148.21823204419888,70,146.1878453038674,70C144.1574585635359,70,142.1270718232044,70,140.0966850828729,70C138.06629834254144,70,136.03591160220995,70,134.00552486187846,70C131.97513812154696,70,129.94475138121547,70,127.91436464088399,70C125.8839779005525,70,123.853591160221,70,121.8232044198895,70C119.79281767955801,70,117.76243093922652,70,115.73204419889503,70C113.70165745856355,70,111.67127071823205,70,109.64088397790056,70C107.61049723756906,70,105.58011049723757,70,103.54972375690608,70C101.51933701657458,70,99.48895027624309,70,97.4585635359116,70C95.4281767955801,70,93.3977900552486,70,91.36740331491713,70C89.33701657458563,70,87.30662983425414,70,85.27624309392264,70C83.24585635359115,70,81.21546961325969,70,79.18508287292819,70C77.1546961325967,70,75.1243093922652,70,73.09392265193371,70C71.06353591160222,70,69.03314917127072,70,67.00276243093923,70C64.97237569060773,70,62.94198895027625,70,60.91160220994475,70C58.88121546961327,70,56.85082872928177,70,54.82044198895028,70C52.790055248618785,70,50.75966850828729,70,48.7292817679558,70C46.6988950276243,70,44.66850828729281,70,42.63812154696132,70C40.60773480662983,70,38.577348066298335,70,36.54696132596685,70C34.51657458563536,70,32.48618784530387,70,30.455801104972377,70C28.425414364640886,70,26.395027624309392,70,24.3646408839779,70C22.334254143646405,70,20.303867403314914,70,18.273480662983424,70C16.243093922651934,70,14.212707182320441,70,12.18232044198895,70C10.151933701657457,70,8.121546961325967,70,6.091160220994475,70C4.060773480662983,70,2.0303867403314917,70,1.0151933701657458,70L0,70Z"></path></g></svg>


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
