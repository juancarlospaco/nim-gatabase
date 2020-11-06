# Gatabase: individual database fields creator is a Walrus operator. KISS.
const nl = when defined(release): " " else: "\n"

template `:=`(dbfield: static string; value: static char): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & dbfield & "\t" & "VARCHAR(1)\tNOT NULL\tDEFAULT '" & $value & "'," & nl

template `:=`(dbfield: static string; value: static SomeFloat): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & dbfield & "\t" & "REAL\tNOT NULL\tDEFAULT "  & $value & "," & nl

template `:=`(dbfield: static string; value: static SomeInteger): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & dbfield & "\t" & "INTEGER\tNOT NULL\tDEFAULT "  & $value & "," & nl

template `:=`(dbfield: static string; value: static bool): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & dbfield & "\t" & "BOOLEAN\tNOT NULL\tDEFAULT "  & (if $value == "true": "1" else: "0") & "," & nl

template `:=`(dbfield: static string; value: static string): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & dbfield & "\t" & "TEXT\tNOT NULL\tDEFAULT '"  & $value & "'," & nl

template `:=`(dbfield: static string; value: typedesc[char]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "VARCHAR(1)," & nl

template `:=`(dbfield: static string; value: typedesc[SomeFloat]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "REAL," & nl

template `:=`(dbfield: static string; value: typedesc[SomeInteger]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "INTEGER," & nl

template `:=`(dbfield: static string; value: typedesc[bool]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "BOOLEAN," & nl

template `:=`(dbfield: static string; value: typedesc[string]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "TEXT," & nl

template `:=`(dbfield: static cstring; value: typedesc[char]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "VARCHAR(1)\tUNIQUE," & nl

template `:=`(dbfield: static cstring; value: typedesc[SomeFloat]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "REAL\tUNIQUE," & nl

template `:=`(dbfield: static cstring; value: typedesc[SomeInteger]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "INTEGER\tUNIQUE," & nl

template `:=`(dbfield: static cstring; value: typedesc[bool]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "BOOLEAN\tUNIQUE," & nl

template `:=`(dbfield: static cstring; value: typedesc[string]): string =
  assert dbfield.len > 0, "Table field name must not be empty string"
  "\t" & $dbfield & "\t" & "TEXT\tUNIQUE," & nl


echo "Gatabase fields with default values"
echo "field0" := 'z'
echo "field1" := 2.0
echo "field2" := 42
echo "field3" := false
echo "field4" := "hello"

echo "Gatabase fields without default values"
echo "field5" := char
echo "field6" := float
echo "field7" := int
echo "field8" := bool
echo "field9" := string

echo "Gatabase fields without default values and UNIQUE restriction"
echo cstring"fielda" := char
echo cstring"fieldb" := float
echo cstring"fieldc" := int
echo cstring"fieldd" := bool
echo cstring"fielde" := string
