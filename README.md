# Gatabase

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/gatabase.png "Compile-Time ORM for Nim")

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg "Compile-Time ORM for Nim")


# Use

- Gatabase is designed as 1 simplified [Strong Static Typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking) [Compile-Time](https://wikipedia.org/wiki/Compile_time) [SQL](https://wikipedia.org/wiki/SQL) [DSL](https://wikipedia.org/wiki/Domain-specific_language) [Sugar](https://en.wikipedia.org/wiki/Syntactic_sugar). Nim mimics SQL.
- Gatabase syntax is almost the same as SQL syntax, [no new ORM to learn ever again](https://pgexercises.com/questions/basic/selectall.html), any [SQL WYSIWYG is your GUI](https://pgmodeler.io/screenshots).
- You can literally [copy&paste a SQL query from StackOverflow](https://stackoverflow.com/questions/tagged/postgresql?tab=Frequent) to Gatabase and with few tiny syntax tweaks is running.
- SQL is Minified when build for Release, Pretty-Printed when build for Debug. It can be assigned to `let` and `const`.


### Support

- All SQL standard syntax is supported.
- ✅ `--` Human readable comments, multi-line comments produce multi-line SQL comments.
- ✅ `COMMENT`, Postgres-only.
- ✅ `UNION`, `UNION ALL`.
- ✅ `CASE` with multiple `WHEN` and `ELSE` with correct indentation.
- ✅ `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`.
- ✅ `OFFSET`.
- ✅ `LIMIT`.
- ✅ `FROM`.
- ✅ `WHERE`, `WHERE NOT`, `WHERE EXISTS`, `WHERE NOT EXISTS`.
- ✅ `ORDER BY`.
- ✅ `SELECT`, `SELECT *`, `SELECT DISTINCT`, `SELECT TOP`, `SELECT MIN`, `SELECT MAX`, `SELECT AVG`, `SELECT SUM`.
- ✅ `DELETE FROM`.
- ✅ `LIKE`, `NOT LIKE`.
- ✅ `BETWEEN`, `NOT BETWEEN`.
- ✅ `HAVING`.
- ✅ `INSERT INTO`.
- ✅ `IS NULL`, `IS NOT NULL`.
- ✅ `UPDATE`.
- ✅ `SET`.
- Deep nested SubQueries are not supported. Postgres version >=12.


### Comments

```sql
-- SQL Comments are supported, but stripped when build for Release. This is SQL.
```

```nim
`--` "SQL Comments are supported, but stripped when build for Release. This is Nim."
```


### SELECT & FROM

```sql
SELECT *
FROM sometable
```

```nim
select '*'
`from` "sometable"
```

---

```sql
SELECT somecolumn
FROM sometable
```

```nim
select "somecolumn"
`from` "sometable"
```

---

```sql
SELECT DISTINCT somecolumn
```

```nim
selectdistinct "somecolumn"
```


### MIN & MAX

```sql
SELECT MIN(somecolumn)
```

```nim
selectmin "somecolumn"
```

---

```sql
SELECT MAX(somecolumn)
```

```nim
selectmax "somecolumn"
```


### COUNT & AVG & SUM

```sql
SELECT COUNT(somecolumn)
```

```nim
selectcount "somecolumn"
```

---

```sql
SELECT AVG(somecolumn)
```

```nim
selectavg "somecolumn"
```

---

```sql
SELECT SUM(somecolumn)
```

```nim
selectsum "somecolumn"
```


### TOP

```sql
SELECT TOP 5 *
```

```nim
selecttop "5"
```


### WHERE

```sql
SELECT somecolumn
FROM sometable
WHERE power > 9000
```

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

```nim
offset 9
limit 42
```


### INSERT

```sql
INSERT INTO person
VALUES (42, 'Nikola Tesla', true, 'nikola.tesla@nim-lang.org', 9.6)
```

```nim
insertinto "person"
values (42, "Nikola Tesla", true, "nikola.tesla@nim-lang.org", 9.6)
```


### DELETE

```sql
DELETE debts
```

```nim
delete "debts"
```


### ORDER BY

```sql
ORDER BY ASC
```

```nim
orderby "asc"
```

---

```sql
ORDER BY DESC
```

```nim
orderby "desc"
```


### UPDATE

```sql
UPDATE tablename
SET key0 = value0, key1 = value1
```

```nim
update "tablename"
`set` {"key0": "value0", "key1": "value1"}
```


### CASE

```sql
CASE
  WHEN foo > 10 THEN 9
  WHEN bar < 42 THEN 5
  ELSE 0
END
```

```nim
`case` {"foo > 10": "9", "bar < 42": "5", "default": "0"}
```


### COMMENT

```sql
COMMENT ON TABLE myTable IS 'This is an SQL COMMENT on a TABLE'
```

```nim
comment {"on": "TABLE", "myTable": "This is an SQL COMMENT on a TABLE"}
```


### GROUP BY

```sql
GROUP BY country
```

```nim
groupby "country"
```


### JOIN

```sql
FULL JOIN tablename
```

```nim
fulljoin "tablename"
```

---

```sql
INNER JOIN tablename
```

```nim
innerjoin "tablename"
```

---

```sql
LEFT JOIN tablename
```

```nim
leftjoin "tablename"
```

---

```sql
RIGHT JOIN tablename
```

```nim
rightjoin "tablename"
```


### HAVING

```sql
HAVING beer > 5
```

```nim
having "beer > 5"
```


### UNION

```sql
UNION ALL
```

```nim
union true
```

---

```sql
UNION
```

```nim
union false
```


### IS NULL

```sql
IS NULL
```

```nim
isnull true
```

---

```sql
IS NOT NULL
```

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
  orderby "desc"
```

**Fails to Compile:**

- `let variable = query Sql: select('*') from("clients") groupby("country") orderby("desc")`
- `let variable = query Sql: '*'.select() "clients".from() "country".groupby() "desc".orderby()`
- `let variable = query Sql: select '*' from "clients" groupby "country" orderby "desc"`
- `let variable = query Sql:select'*' from"clients" groupby"country" orderby"desc"`

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
this allows to support interesting features, like `CASE`, `UNION`, `COMMENT`, etc.


# Output

ORM Output is choosed from `GatabaseOutput` [`enum` type](https://nim-lang.github.io/Nim/manual.html#types-enumeration-types), MetaProgramming generates different output code. Examples:

- `query Func:` generates 1 [anonymous inlined function](https://nim-lang.github.io/Nim/manual.html#procedures-anonymous-procs) `( func (): SqlQuery = ... )`.
- `query Prepared:` generates 1 Postgres Stored Procedure of [`SqlPrepared` type](https://nim-lang.github.io/Nim/db_postgres.html#parameter-substitution).
- `query TryExec:` generates code for 1 [`tryExec()` function](https://nim-lang.github.io/Nim/db_postgres.html#tryExec%2CDbConn%2CSqlQuery%2Cvarargs%5Bstring%2C%5D), etc etc etc.
- Compile using `-d:dev` for Debugging of the generated SQL.

See `nim doc gatabase.nim`, `runnableExamples`, [Std Lib db_postgres](https://nim-lang.github.io/Nim/db_postgres.html) for more documentation.


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
  [OK] const INSERT INTO
  [OK] const SELECT ... FROM ... WHERE
  [OK] const SELECT ... (comment) ... FROM ... COMMENT
  [OK] const SELECT ... FROM ... LIMIT ... OFFSET
  [OK] const INSERT INTO
  [OK] const UNION ALL ... ORBER BY ... IS NOT NULL
  [OK] const SELECT DISTINCT ... FROM ... WHERE
  [OK] var   CASE
  [OK] var   DELETE FROM WHERE

```

- Tests use a real database SQLite on RAM `":memory:"` with a `"person"` table.


# Install

- [`nimble install gatabase`](https://nimble.directory/pkg/gatabase "nimble install gatabase 👑 https://nimble.directory/pkg/gatabase")


# Requisites

- **None.** _(You need a working Postgres server up & running to use it, but not to install it)_


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

- This works with Synchronous code ?.

Yes.

- This works with Asynchronous code ?.

Yes.

- SQLite mode dont support some stuff ?.

We try to keep as similar as possible, but SQLite is very limited.

</details>
