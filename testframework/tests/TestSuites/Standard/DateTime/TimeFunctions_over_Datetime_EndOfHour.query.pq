/*
Note: This tests will fail for BigQuery ADBC & ODBC because of the below bug:
Bug 1769126: ADBC - BigQuery -  DateFunctions_over_Datetime_EndOfWeek.query.pq, DateFunctions_over_Datetime_StartOfWeek.query.pq & TimeFunctions_over_Datetime_EndOfHour.query.pq tests fail due to difference in datetime precision
*/
(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "eoh", each Time.EndOfHour([lpep_pickup_datetime])),
    T_Sorted = Table.Sort(T2, "RecordID"),
    selected = Table.SelectColumns(T_Sorted, {"RecordID", "lpep_pickup_datetime", "eoh"}),
    T_FirstN = Table.FirstN(selected, 1)
in
    T_FirstN

