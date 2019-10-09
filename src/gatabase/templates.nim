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
  doAssert value.kind == nnkIdent and parseBool($value), "IS NULL must be bool"
  if parseBool($value): static("IS NULL" & n) else: static("IS NOT NULL" & n)


template updates(value: NimNode): string =
  isQuestionOrString(value)
  if isQuestionChar(value): static("UPDATE ?" & n)
  else: "UPDATE " & $value.strVal & n # TODO: SET


template unions(value: NimNode): string =
  doAssert value.kind == nnkIdent and parseBool($value), "UNION must be bool"
  if parseBool($value): static("UNION ALL" & n) else: static("UNION" & n)
