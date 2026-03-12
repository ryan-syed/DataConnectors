(parameter) =>
let
    T1 = Table.AddColumn(parameter[taxi_table], "EOD", each Date.EndOfDay([lpep_dropoff_datetime])),
    T2 = Table.SelectColumns(T1, {"RecordID","lpep_dropoff_datetime","EOD"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    TA = Table.FirstN(T3, 1)
in
    Table.Buffer(TA)
