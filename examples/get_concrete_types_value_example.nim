import db_sqlite
import ../src/gatabase
include prelude, ../src/gatabase/sugar
let db = db_sqlite.open(":memory:", "", "", "")
db.exec(sql"""
  create table if not exists person(
    id        integer       primary key,
    name      varchar(9)    not null    unique,
    active    bool          not null    default true,
    rank      float         not null    default 0.0,
    sex       varchar(1)    not null    default 'f',
    age       integer       not null    default 18
  ); """)
db.exec(sql"insert into person values (42, 'pepe', true, 9.6, 'm', 25);")
let myRow: Row = [].getRow:
  select '*'
  `from` "person"
doAssert myRow == @["42", "pepe", "1", "9.6", "m", "25"]


# ^ Boilerplate for the example, ignore it ### Get concrete types:


# Get a byte
doAssert byte(0).myRow is byte               # byte(42)
# Get a char
doAssert '4'.myRow is char                   # char('m')
# Get a byte
doAssert cstring"1".myRow is cstring         # cstring("pepe")
# Get a float
doAssert 3.0.myRow is float                  # float(9.6)
# Get a float32
doAssert 3.0'f32.myRow is float32            # float32(9.6)
# Get an int
doAssert 0.myRow is int                      # 42
# Get a Natural
doAssert Natural(0).myRow is Natural         # Natural(42)
# Get a Positive
doAssert Positive(2).myRow is Positive       # Positive(1)
# Get a cint
doAssert cint(0).myRow is cint               # cint(42)
# Get a int8
doAssert 0'i8.myRow is int8                  # int8(42)
# Get a int16
doAssert 0'i16.myRow is int16                # int16(42)
# Get a int32
doAssert 0'i32.myRow is int32                # int32(42)
# Get a int64
doAssert 0'i64.myRow is int64                # int64(42)
# Get a uint8
doAssert 0'u8.myRow is uint8                 # uint8(42)
# Get a uint16
doAssert 0'u16.myRow is uint16               # uint16(42)
# Get a uint32
doAssert 0'u32.myRow is uint32               # uint32(42)
# Get a uint64
doAssert 0'u64.myRow is uint64               # uint64(42)
# Get a BiggestInt
doAssert BiggestInt(0).myRow is BiggestInt   # BiggestInt(42)
# Get a BiggestUInt
doAssert BiggestUInt(0).myRow is BiggestUInt # BiggestUInt(42)
