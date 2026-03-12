(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T7 = Table.AddColumn(T3, "EOM", each Date.EndOfMonth([lpep_dropoff_datetime])),
    T9 = Table.FirstN(T7, 1)
in
    T9
