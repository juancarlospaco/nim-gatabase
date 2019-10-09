# DEPRECATED, DONT USE,DEPRECATED, DONT USE,DEPRECATED, DONT USE,DEPRECATED, DONT USE,DEPRECATED, DONT USE,DEPRECATED, DONT USE

# Gatabase

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg "Compile-Time ORM for Nim")


# Features

- [Postgres >= 10](https://www.postgresql.org) and [SQLite](https://sqlite.org), Async and Sync.
- UTF-8 encoding.
- [All SQL are `const`.](https://nim-lang.org/docs/manual.html#statements-and-expressions-const-section)
- Database user must have a password.
- Database connection is to hostname.
- [Self-Documentation Comments supported  (Postgres).](https://www.postgresql.org/docs/11/sql-comment.html)
- [Configurable AutoVacuum supported  (Postgres).](https://www.postgresql.org/docs/11/runtime-config-autovacuum.html)
- Backups for Databases supported.
- The `timeout` argument is on Seconds.
- `DISTINCT` supported on SQL, `bool` type, `false` by default.
- `LIMIT` supported on SQL, `int` type, `int.high` by default.
- `OFFSET` supported on SQL, `int` type, `0` by default.
- No OS-specific code, so it should work on Linux, Windows and Mac.
- Compatible with [`db_postgres`](https://nim-lang.org/docs/db_postgres.html) and [Ormin](https://github.com/Araq/ormin).
- You can still use std lib `db_postgres` and `db_sqlite` as normal (same connection).
- You can write with Gatabase and read with Ormin.
- [Functional, all functions are `func` (Effects free).](https://nim-lang.org/docs/manual.html#procedures-func)
- Debug raw SQL when not build for Release.
- Table Helpers (ready-made Table templates for common uses).
- Single file. 0 Dependency. Self-Documented.
- Compile with `-d:sqlite` to enable SQLite and disable Postgres.
- Compile with `-d:noFields` to disable Fields feature, for smaller binary (Kb), etc.
- No code for Postgres when compiled for SQLite, no code for SQLite when compiled for Postgres.
- Run `nim doc gatabase.nim` for more Documentation. `runnableExamples` provided.
- Run `nim c -r gatabase.nim` for an Example.
- **Pull Requests welcome!.**


# Use

- Gatabase is designed as a simplified [Compile-Time](https://wikipedia.org/wiki/Compile_time) [SQL](https://wikipedia.org/wiki/SQL) [DSL](https://wikipedia.org/wiki/Domain-specific_language).
- Gatabase syntax is almost the same as SQL syntax, no new ORM to learn.
- SQL is Minified when build for Release, Pretty-Printed when build for Debug.

### Comments

```sql
-- SQL Comments are supported, but stripped when build for Release. This is SQL.
```

```nim
`--` "SQL Comments are supported, but stripped when build for Release. This is Nim."
```

### Wildcards

- SQL `*` is `'*'` on Nim.
- Nim `'?'` generates `?` to be replaced by values from args.

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
FROM sometable
```

```nim
selectdistinct "somecolumn"
`from` "sometable"
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
INSERT INTO tablename
```

```nim
insertinto "tablename"
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



# Install

- `nimble install gatabase`


# Requisites

- **None.** _(You need a working Postgres server up & running to use it, but not to install it)_


# FAQ

<details>

- Supports SQLite ?.

Yes.

- Supports MySQL ?.

No.

- Will support MySQL someday ?.

No.

- This works with Synchronous code ?.

Yes.

- This works with Asynchronous code ?.

Yes.

- SQLite mode dont support some stuff ?.

We try to keep as similar as possible, but SQLite is very limited.

</details>


- [Recommended tool for SQL, Open source Qt5/C++ WYSIWYG & Drag'n'Drop graphical query builder.](https://pgmodeler.io/screenshots)
- [Learn SQL once, so you dont have to learn several ORMs, is actually very easy to learn.](https://pgexercises.com/questions/basic/selectall.html)
