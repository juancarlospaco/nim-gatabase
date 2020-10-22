import db_sqlite
import gatabase
include gatabase/sugar

let myTable = createTable "kitten": [
  "age"  := 1,
  "sex"  := 'f',
  "name" := "fluffy",
  "rank" := 3.14,
]

echo myTable.string
