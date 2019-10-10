# Gatabase

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/gatabase.png "Compile-Time ORM for Nim")

![screenshot](https://raw.githubusercontent.com/juancarlospaco/nim-gatabase/master/temp.jpg "Compile-Time ORM for Nim")


# Use

- Gatabase is designed as a simplified [Strong Static Typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking) [Compile-Time](https://wikipedia.org/wiki/Compile_time) [SQL](https://wikipedia.org/wiki/SQL) [DSL](https://wikipedia.org/wiki/Domain-specific_language) [Sugar](https://en.wikipedia.org/wiki/Syntactic_sugar).
- Gatabase syntax is almost the same as SQL syntax, no new ORM to learn ([learn SQL](https://pgexercises.com/questions/basic/selectall.html)).
- SQL is Minified when build for Release, Pretty-Printed when build for Debug.
- All the SQL syntax is supported. `CASE`, `UNION`, `JOIN` supported. Deep nested SubQueries are not supported.

```nim
let variable = query sql:
  select  '*'
  `from`  "clients"
  groupby "country"
  orderby "desc"
```

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


# Output

ORM Output is choosed from `ormOutput` of `enum` type, MetaProgramming generates different output code. Examples:

- `query anonFunc:` generates 1 anonimous inlined function `(func (): SqlQuery = ... )`.
- `query sqlPrepared:` generates 1 Postgres Stored Procedure of `SqlPrepared` type.
- `query tryExec:` generates code for 1 `tryExec()` function, etc etc.

See `nim doc gatabase.nim` and `runnableExamples`.


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
