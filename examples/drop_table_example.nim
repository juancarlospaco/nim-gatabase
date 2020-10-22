import db_sqlite
import gatabase
include gatabase/sugar


let db = open(":memory:", "", "", "")
db.exec(sql"""
  create table if not exists person(
    id      integer     primary key,
    name    varchar(9)  not null unique,
  ); """)

assert db.dropTable "person"
