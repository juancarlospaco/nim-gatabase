import db_common, gatabase

let variable = query Sql:
  delete "debts"

echo variable.string
