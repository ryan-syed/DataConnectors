/*
Note: This tests will fail for BigQuery ADBC & ODBC because of the below bug:
Bug 1769126: ADBC - BigQuery -  DateFunctions_over_Datetime_EndOfWeek.query.pq, DateFunctions_over_Datetime_StartOfWeek.query.pq & TimeFunctions_over_Datetime_EndOfHour.query.pq tests fail due to difference in datetime precision
*/
(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOW", each Date.StartOfWeek([lpep_dropoff_datetime])),
    T9 = Table.FirstN(T4, 1)
in
    Table.Buffer(T9)
