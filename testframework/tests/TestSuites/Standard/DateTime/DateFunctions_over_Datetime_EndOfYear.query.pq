(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "EOY", each Date.EndOfYear([lpep_dropoff_datetime])),
    T9 = Table.FirstN(T5, 1)
in
    Table.Buffer(T9)
