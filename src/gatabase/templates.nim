# Tiny compile-time internal templates that do 1 thing, do NOT put other logic here.
from strutils import join

const n = when defined(release): " " else: "\n"

func parseBool(s: string): bool {.inline.} =
  case s # Optimized stricter version, no lowercase,
  of "true": result = true # only "true" or "false",
  of "false": result = false # not "y" nor "n", etc.
  else: doAssert false, "cannot interpret as a bool"

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


template isArrayStr(value: NimNode) =
  doAssert value.kind == nnkBracket, "value must be Array"
  doAssert value.len > 0, "value must be 1 Non Empty Array"
  for t in value: doAssert t.strVal.len > 0, "Array items must not be empty string"


template sqlComment(comment: string): string =
  doAssert comment.len > 0, "SQL Comment must not be empty string"
  when defined(release): n
  else: "/* " & $comment & static(" */" & n)


template offsets(value: NimNode): string =
  isQuestionOrNatural(value)
  if isQuestionChar(value): static("OFFSET ?" & n)
  else: "OFFSET " & $value.intVal.Natural & n


template limits(value: NimNode): string =
  isQuestionOrPositive(value)
  if isQuestionChar(value): static("LIMIT ?" & n)
  else: "LIMIT " & $value.intVal.Positive & n


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
  doAssert value.strVal.len > 0, "ORDER BY must not be empty string"
  "ORDER BY " & $value.strVal & n


template selects(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT ?" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT *" & n
  else: "SELECT " & $value.strVal & n


template selectDistincts(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT DISTINCT ?" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT DISTINCT *" & n
  else: "SELECT DISTINCT " & $value.strVal & n


template selectTops(value: NimNode): string =
  isQuestionOrPositive(value)
  if isQuestionChar(value): static("SELECT TOP ? *" & n)
  else: "SELECT TOP " & $value.intVal & " *" & n


template selectMins(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT MIN(?)" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT MIN(*)" & n
  else: "SELECT MIN(" & $value.strVal & ")" & n


template selectMaxs(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT MAX(?)" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT MAX(*)" & n
  else: "SELECT MAX(" & $value.strVal & ")" & n


template selectCounts(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT COUNT(?)" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT COUNT(*)" & n
  else: "SELECT COUNT(" & $value.strVal & ")" & n


template selectAvgs(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT AVG(?)" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT AVG(*)" & n
  else: "SELECT AVG(" & $value.strVal & ")" & n


template selectSums(value: NimNode): string =
  isCharOrString(value)
  if isQuestionChar(value): static("SELECT SUM(?)" & n)
  elif value.kind == nnkCharLit:
    when not defined(release) or not defined(danger):
      {.warning: "SELECT * is bad practice https://stackoverflow.com/a/3639964".}
    "SELECT SUM(*)" & n
  else: "SELECT SUM(" & $value.strVal & ")" & n


template selectTrims(value: NimNode): string =
  isCharOrString(value)
  "SELECT trim(lower(" & $value.strVal & static("))" & n)


template selectRound2(value: NimNode): string =
  isCharOrString(value)
  "SELECT round(" & $value.strVal & static(", 2)" & n)


template selectRound4(value: NimNode): string =
  isCharOrString(value)
  "SELECT round(" & $value.strVal & static(", 4)" & n)


template selectRound6(value: NimNode): string =
  isCharOrString(value)
  "SELECT round(" & $value.strVal & static(", 6)" & n)


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


template unions(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value), "UNION must be bool"
  if parseBool($value): static("UNION ALL" & n) else: static("UNION" & n)


template intersects(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value), "INTERSECT must be bool"
  if parseBool($value): static("INTERSECT ALL" & n) else: static("INTERSECT" & n)


template excepts(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value), "EXCEPT must be bool"
  if parseBool($value): static("EXCEPT ALL" & n) else: static("EXCEPT" & n)


template updates(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("UPDATE ?" & n)
  else: "UPDATE " & $value.strVal & n


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


template values(value: Positive): string =
  # Produces "VALUES (?, ?, ?)", values passed via varargs.
  var temp = newSeqOfCap[char](value - 1)
  for i in 0 ..< value: temp.add '?'
  "VALUES ( " & temp.join", " & static(" )" & n)


template sets(value: NimNode): string =
  # Produces "SET key = ?, key = ?, key = ?", values passed via varargs.
  isArrayStr(value)
  var temp = newSeqOfCap[string](value.len)
  for item in value:
    temp.add item.strVal & " = ?"
  "SET " & temp.join", " & n


template comments(value: NimNode, what: string): string =
  isTable(value)
  when defined(postgres):
    doAssert value.len == 1, "COMMENT wrong SQL syntax, must have exactly 1 key"
    var name, coment: string
    for tableValue in value:
      name = tableValue[0].strVal
      coment = tableValue[1].strVal
      doAssert name.len > 0, "COMMENT 'name' value must not be empty string"
      doAssert coment.len > 0, "COMMENT value must not be empty string"
    "COMMENT ON " & what & " " & name & " IS '" & coment & "'" & n
  else: n # SQLite wont support COMMENT, is not part of SQL Standard neither.


template cases(value: NimNode): string =
  isTable(value)
  doAssert value[^1][0].strVal == "else", "CASE must have 1 'else' key, as last key, is required and mandatory"
  var defaultFound: byte
  var default, branches: string
  for tableValue in value:
    if tableValue[0].strVal == "else":
      default = "  ELSE " & tableValue[1].strVal & n
      inc defaultFound
    else:
      branches.add "  WHEN " & tableValue[0].strVal & " THEN " & tableValue[1].strVal & n
  doAssert defaultFound == 1, "CASE must have 1 'else' key, but found: " & $defaultFound
  n & static("(CASE" & n) & branches & default & static("END)" & n)
