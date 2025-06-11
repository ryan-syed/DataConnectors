(parameter) => 
let
    Columns = [
        AddDay = each [lpep_pickup_date] + #duration(1,0,0,0),
        AddHour = each [lpep_pickup_date] + #duration(0,1,0,0),
        AddMinute = each [lpep_pickup_date] + #duration(0,0,1,0),
        AddSecond = each [lpep_pickup_date] + #duration(0,0,0,1),
        AddAll = each [lpep_pickup_date] + #duration(1,1,1,1.25),
        Subtract = each [lpep_pickup_date] - #duration(1,1,1,1.25)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), parameter[taxi_date_table],
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    Sorted = Table.Sort(AddColumns,{"RecordID", Order.Descending}),
    FirstN = Table.FirstN(Sorted,5)
in
    FirstN