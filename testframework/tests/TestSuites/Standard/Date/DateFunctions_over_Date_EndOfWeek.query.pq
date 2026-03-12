(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    TC = Table.AddColumn(T3, "EOW", each Date.EndOfWeek([lpep_pickup_date])),
    TE = Table.FirstN(TC, 1)
in
    Table.Buffer(TE)