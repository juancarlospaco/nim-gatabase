## Gatabase Sugar
## ==============
##
## Syntax Sugar for Gatabase using `{.experimental: "dotOperators".}` and `template`,
## include or import *after* importing `db_sqlite` or `db_postgres` to use it on your code.
{.experimental: "dotOperators".}

template `.`*(indx: int; data: Row): int = parseInt(data[indx])               ## `9.row` alias for `parseint(row[9])`.
template `.`*(indx: char; data: Row): char = char(data[parseInt(indx)])       ## `'9'.row` alias for `char(row[9])`.
template `.`*(indx: uint; data: Row): uint = uint(parseInt(data[indx]))       ## `9'u.row` alias for `uint(parseint(row[9]))`.
template `.`*(indx: cint; data: Row): cint = cint(parseInt(data[indx]))       ## `cint(9).row` alias for `cint(parseint(row[9]))`.
template `.`*(indx: int8; data: Row): int8 = int8(parseInt(data[indx]))       ## `9'i8.row` alias for `int8(parseint(row[9]))`.
template `.`*(indx: byte; data: Row): byte = byte(parseInt(data[indx]))       ## `byte(9).row` alias for `byte(parseint(row[9]))`.
template `.`*(indx: int16; data: Row): int16 = int16(parseInt(data[indx]))    ## `9'i16.row` alias for `int16(parseint(row[9]))`.
template `.`*(indx: int32; data: Row): int32 = int32(parseInt(data[indx]))    ## `9'i32.row` alias for `int32(parseint(row[9]))`.
template `.`*(indx: int64; data: Row): int64 = int64(parseInt(data[indx]))    ## `9'i64.row` alias for `int64(parseint(row[9]))`.
template `.`*(indx: uint8; data: Row): uint8 = uint8(parseInt(data[indx]))    ## `9'i64.row` alias for `uint8(parseint(row[9]))`.
template `.`*(indx: uint16; data: Row): uint16 = uint16(parseInt(data[indx])) ## `9'i64.row` alias for `uint16(parseint(row[9]))`.
template `.`*(indx: uint32; data: Row): uint32 = uint32(parseInt(data[indx])) ## `9'i64.row` alias for `uint32(parseint(row[9]))`.
template `.`*(indx: uint64; data: Row): uint64 = uint64(parseInt(data[indx])) ## `9'i64.row` alias for `uint64(parseint(row[9]))`.
template `.`*(indx: float; data: Row): float = parseFloat(data[parseInt(indx)])              ## `9.0.row` alias for `parseFloat(row[9])`.
template `.`*(indx: Natural; data: Row): Natural = Natural(parseInt(data[indx]))             ## `Natural(9).row` alias for `Natural(parseint(row[9]))`.
template `.`*(indx: cstring; data: Row): cstring = cstring(data[parseInt($indx)])            ## `cstring("9").row` alias for `cstring(row[9])`.
template `.`*(indx: Positive; data: Row): Positive = Positive(parseInt(data[indx]))          ## `Positive(9).row` alias for `Positive(parseint(row[9]))`.
template `.`*(indx: BiggestInt; data: Row): BiggestInt = BiggestInt(parseInt(data[indx]))    ## `BiggestInt(9).row` alias for `BiggestInt(parseint(row[9]))`.
template `.`*(indx: BiggestUInt; data: Row): BiggestUInt = BiggestUInt(parseInt(data[indx])) ## `BiggestUInt(9).row` alias for `BiggestUInt(parseint(row[9]))`.
template `.`*(indx: float32; data: Row): float32 = float32(parseFloat(data[parseInt(indx)])) ## `9.0'f32.row` alias for `float32(parseFloat(row[9]))`.
