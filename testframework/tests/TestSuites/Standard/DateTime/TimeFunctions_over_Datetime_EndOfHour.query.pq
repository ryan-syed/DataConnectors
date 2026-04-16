(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID", "lpep_pickup_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T8 = Table.AddColumn(T3, "eoh", each Time.EndOfHour([lpep_pickup_datetime])),
    T_FirstN = Table.FirstN(T8, 1),
    TA = Table.TransformColumns(T_FirstN, {"eoh", each let d = _ in #datetime(Date.Year(d), Date.Month(d), Date.Day(d), Time.Hour(d), Time.Minute(d), Number.RoundDown(Time.Second(d)))})
in
    TA
