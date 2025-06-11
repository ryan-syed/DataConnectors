(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([lpep_pickup_date])),
    T5 = Table.AddColumn(T4, "M", each Date.Month([lpep_pickup_date])),
    T6 = Table.AddColumn(T5, "D", each Date.Day([lpep_pickup_date])),
    T7 = Table.AddColumn(T6, "QOY", each Date.QuarterOfYear([lpep_pickup_date])),
    T8 = Table.AddColumn(T7, "WOY", each Date.WeekOfYear([lpep_pickup_date])),
    T9 = Table.AddColumn(T8, "DOY", each Date.DayOfYear([lpep_pickup_date])),
    TA = Table.FirstN(T9, 4)
in
    TA