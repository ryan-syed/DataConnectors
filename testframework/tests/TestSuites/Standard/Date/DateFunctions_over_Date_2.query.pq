(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOY", each Date.ToText(Date.StartOfYear([lpep_pickup_date]))),
    T5 = Table.AddColumn(T4, "SOQ", each Date.ToText(Date.StartOfQuarter([lpep_pickup_date]))),
    T6 = Table.AddColumn(T5, "SOM", each Date.ToText(Date.StartOfMonth([lpep_pickup_date]))),
    T7 = Table.AddColumn(T6, "SOW", each Date.ToText(Date.StartOfWeek([lpep_pickup_date]))),
    T8 = Table.AddColumn(T7, "SOD", each Date.ToText(Date.StartOfDay([lpep_pickup_date]))),
    T9 = Table.AddColumn(T8, "EOY", each Date.ToText(Date.EndOfYear([lpep_pickup_date]))),
    TA = Table.AddColumn(T9, "EOQ", each Date.ToText(Date.EndOfQuarter([lpep_pickup_date]))),
    TB = Table.AddColumn(TA, "EOM", each Date.ToText(Date.From(Date.EndOfMonth([lpep_pickup_date])))),
    TC = Table.AddColumn(TB, "EOW", each Date.ToText(Date.EndOfWeek([lpep_pickup_date]))),
    TD = Table.AddColumn(TC, "EOD", each Date.ToText(Date.EndOfDay([lpep_pickup_date]))),
    TE = Table.FirstN(TD, 4)
in
    TE