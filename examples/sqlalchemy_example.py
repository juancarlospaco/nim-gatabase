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
  ); """)


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
