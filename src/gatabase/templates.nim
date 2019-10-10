## Tiny compile-time internal templates that do 1 thing, do NOT put other logic here.

const n = when defined(release): " " else: "\n"


template isQuestionChar(value: NimNode): bool =
  unlikely(value.kind == nnkCharLit and value.intVal == 63)


template isQuestionOrNatural(value: NimNode) =
  doAssert value.kind in {nnkIntLit, nnkCharLit}, "value must be Natural or '?'"
  if value.kind == nnkCharLit: doAssert value.intVal == 63, "value must be '?'"
  if value.kind == nnkIntLit: doAssert Natural(value.intVal) is int, "value must be Natural"


template isQuestionOrPositive(value: NimNode) =
  doAssert value.kind in {nnkIntLit, nnkCharLit}, "value must be Natural or '?'"
  if value.kind == nnkCharLit: doAssert value.intVal == 63, "value must be '?'"
  if value.kind == nnkIntLit: doAssert Positive(value.intVal) is int, "value must be Positive"


template isQuestionOrString(value: NimNode) =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "value must be string or '?'"
  if value.kind == nnkCharLit: doAssert value.intVal == 63, "value must be '?'"
  if value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit}: doAssert value.strVal.len > 0, "value must not be empty string"


template isCharOrString(value: NimNode) =
  doAssert value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit, nnkCharLit}, "value must be string or '?' or '*'"
  if value.kind == nnkCharLit: doAssert value.intVal == 63 or value.intVal == 42, "value must be '?' or '*'"
  if value.kind in {nnkStrLit, nnkTripleStrLit, nnkRStrLit}: doAssert value.strVal.len > 0, "value must not be empty string"


template isTable(value: NimNode) =
  doAssert value.kind == nnkTableConstr, "value must be Table"
  doAssert value.len > 0, "value must be 1 Non Empty Table"
  for t in value: doAssert t[0].strVal.len > 0, "Table keys must not be empty string"


template isTuple(value: NimNode) =
  echo value.kind
  doAssert value.kind == nnkTupleTy, "values must be Tuple"
  doAssert value.len > 0, "values must be 1 Non Empty Tuple"


template sqlComment(comment: string): string =
  doAssert comment.len > 0, "SQL Comment must not be empty string"
  when defined(release): n
  else:
    if comment.countLines == 1: "-- " & $comment.strip & n
    else: "/* " & $comment.strip & static(" */" & n)


template offsets(value: NimNode): string =
  isQuestionOrNatural(value)
  if isQuestionChar(value): static("OFFSET ?" & n)
  else: "OFFSET " & $value.intVal.Natural & n


template limits(value: NimNode): string =
  isQuestionOrPositive(value)
  if isQuestionChar(value): static("LIMIT ?" & n)
  else: "LIMIT " & $value.intVal.Positive & n


template values(value: Positive): string =
  var temp: seq[string]
  for i in 0 ..< value: temp.add "?"
  "VALUES ( " & temp.join", " & static(" )" & n)


template froms(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("FROM ?" & n)
  else: "FROM " & $value.strVal & n


template wheres(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("WHERE ?" & n)
  else: "WHERE " & $value.strVal & n


template whereNots(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("WHERE NOT ?" & n)
  else: "WHERE NOT " & $value.strVal & n


template whereExists(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("WHERE EXISTS ?" & n)
  else: "WHERE EXISTS " & $value.strVal & n


template whereNotExists(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("WHERE NOT EXISTS ?" & n)
  else: "WHERE NOT EXISTS " & $value.strVal & n


template orderbys(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("ORDER BY ?" & n)
  else:
    if value.strVal == "asc": static("ORDER BY ASC" & n)
    elif value.strVal == "desc": static("ORDER BY DESC" & n)
    else: "ORDER BY " & $value.strVal & n


template selects(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT ?" & n)
  elif value.kind == nnkCharLit: static("SELECT *" & n)
  else: "SELECT " & $value.strVal & n


template selectDistincts(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT DISTINCT ?" & n)
  elif value.kind == nnkCharLit: static("SELECT DISTINCT *" & n)
  else: "SELECT DISTINCT " & $value.strVal & n


template selectTops(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT TOP ? *" & n)
  else: "SELECT TOP " & $value.strVal & " *" & n


template selectMins(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT MIN(?)" & n)
  elif value.kind == nnkCharLit: static("SELECT MIN(*)" & n)
  else: "SELECT MIN(" & $value.strVal & ")" & n


template selectMaxs(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT MAX(?)" & n)
  elif value.kind == nnkCharLit: static("SELECT MAX(*)" & n)
  else: "SELECT MAX(" & $value.strVal & ")" & n


template selectCounts(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT COUNT(?)" & n)
  elif value.kind == nnkCharLit: static("SELECT COUNT(*)" & n)
  else: "SELECT COUNT(" & $value.strVal & ")" & n


template selectAvgs(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT AVG(?)" & n)
  elif value.kind == nnkCharLit: static("SELECT AVG(*)" & n)
  else: "SELECT AVG(" & $value.strVal & ")" & n


template selectSums(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT SUM(?)" & n)
  elif value.kind == nnkCharLit: static("SELECT SUM(*)" & n)
  else: "SELECT SUM(" & $value.strVal & ")" & n


template deletes(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("DELETE FROM ?" & n)
  else: "DELETE FROM " & $value.strVal & n


template likes(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("LIKE ?" & n)
  else: "LIKE " & $value.strVal & n


template notlikes(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("NOT LIKE ?" & n)
  else: "NOT LIKE " & $value.strVal & n


template betweens(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("BETWEEN ?" & n)
  else: "BETWEEN " & $value.strVal & n


template notbetweens(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("NOT BETWEEN ?" & n)
  else: "NOT BETWEEN " & $value.strVal & n


template innerjoins(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("INNER JOIN ?" & n)
  else: "INNER JOIN " & $value.strVal & n


template leftjoins(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("LEFT JOIN ?" & n)
  else: "LEFT JOIN " & $value.strVal & n


template rightjoins(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("RIGHT JOIN ?" & n)
  else: "RIGHT JOIN " & $value.strVal & n


template fulljoins(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("FULL OUTER JOIN ?" & n)
  else: "FULL OUTER JOIN " & $value.strVal & n


template groupbys(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("GROUP BY ?" & n)
  else: "GROUP BY " & $value.strVal & n


template havings(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("HAVING ?" & n)
  else: "HAVING " & $value.strVal & n


template intos(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("INTO ?" & n)
  else: "INTO " & $value.strVal & n


template inserts(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("INSERT INTO ?" & n)
  else: "INSERT INTO " & $value.strVal & n


template isnulls(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value) is bool, "IS NULL must be bool"
  if parseBool($value): static("IS NULL" & n) else: static("IS NOT NULL" & n)


template updates(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("UPDATE ?" & n)
  else: "UPDATE " & $value.strVal & n


template unions(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value), "UNION must be bool"
  if parseBool($value): static("UNION ALL" & n) else: static("UNION" & n)


template comments(value: NimNode): string =
  isTable(value)
  when defined(postgres):
    doAssert value.len == 2, "COMMENT wrong SQL syntax, must have exactly 2 keys"
    doAssert value[0][0].strVal == "on", "COMMENT must have 1 'on' key, as first key, is required and mandatory"
    var onFound: byte
    var what, name, coment: string
    for tableValue in value:
      if tableValue[0].strVal == "on":
        what = tableValue[1].strVal.strip
        doAssert what.len > 0, "COMMENT 'on' value must not be empty string"
        inc onFound
      else:
        name = tableValue[0].strVal.strip
        coment = tableValue[1].strVal.strip
        doAssert name.len > 0, "COMMENT 'name' value must not be empty string"
    doAssert onFound == 1, "COMMENT must have 1 'on' key, but found: " & $onFound
    "COMMENT ON " & what & " " & name & " IS '" & coment & "'" & n
  else: n # SQLite wont support COMMENT, is not part of SQL Standard neither.


template sets(value: NimNode): string =
  isTable(node[1])
  var temp: seq[string]
  for tableValue in node[1]:
    temp.add tableValue[0].strVal & " = " & tableValue[1].strVal
  "SET " & temp.join", "


template cases(value: NimNode): string =
  isTable(value)
  doAssert value[^1][0].strVal == "default", "CASE must have 1 'default' key, as last key, is required and mandatory"
  var defaultFound: byte
  var default, branches: string
  for tableValue in value:
    if tableValue[0].strVal == "default":
      default = "  ELSE " & tableValue[1].strVal & n
      inc defaultFound
    else:
      branches.add "  WHEN " & tableValue[0].strVal & " THEN " & tableValue[1].strVal & n
  doAssert defaultFound == 1, "CASE must have 1 'default' key, but found: " & $defaultFound
  n & static("(CASE" & n) & branches & default & static("END)" & n)


template resetAllGuards() =
  # Union can "Reset" select, from, where, etc to be re-used again on new query
  offsetUsed = false
  limitUsed = false
  fromUsed = false
  whereUsed = false
  orderUsed = false
  selectUsed = false
  deleteUsed = false
  likeUsed = false
  valuesUsed = false
  betweenUsed = false
  joinUsed = false
  groupbyUsed = false
  havingUsed = false
  intoUsed = false
  insertUsed = false
  isnullUsed = false
  updateUsed = false
