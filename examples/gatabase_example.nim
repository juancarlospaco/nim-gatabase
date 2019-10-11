import db_sqlite, ../src/gatabase

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
