(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "EOY", each Date.EndOfYear([lpep_dropoff_datetime])),
    T9 = Table.FirstN(T5, 1),
    TA = Table.TransformColumns(T9, {"EOY", each let d = _ in #datetime(Date.Year(d), Date.Month(d), Date.Day(d), Time.Hour(d), Time.Minute(d), Number.RoundDown(Time.Second(d)))})
in
    Table.Buffer(TA)