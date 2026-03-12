(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T7 = Table.AddColumn(T3, "SOW", each Date.StartOfWeek([lpep_pickup_date])),
    TE = Table.FirstN(T7, 1)
in
    Table.Buffer(TE)
