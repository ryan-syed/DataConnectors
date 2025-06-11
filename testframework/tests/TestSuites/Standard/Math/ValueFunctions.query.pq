(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T2 = Table.AddColumn(T1,"MultiplyDefault",each Value.Multiply([passenger_count],[total_amount])),
    T3 = Table.AddColumn(T2,"MultiplyDoublePrecision", each Value.Multiply([passenger_count],[total_amount],Precision.Double)),
    T4 = Table.AddColumn(T3,"MultiplyDecimalPrecision", each Value.Multiply([passenger_count],[total_amount],Precision.Decimal)),
    T5 = Table.AddColumn(T4,"AddDefault",each Value.Add([passenger_count],[total_amount])),
    T6 = Table.AddColumn(T5,"AddDoublePrecision", each Value.Add([passenger_count],[total_amount],Precision.Double)),
    T7 = Table.AddColumn(T6,"AddDecimalPrecision", each Value.Add([passenger_count],[total_amount],Precision.Decimal)),
    T8 = Table.AddColumn(T7,"SubtractDefault",each Value.Subtract([passenger_count],[total_amount])),
    T9 = Table.AddColumn(T8,"SubtractDoublePrecision", each Value.Subtract([passenger_count],[total_amount],Precision.Double)),
    T10 = Table.AddColumn(T9,"SubtractDecimalPrecision", each Value.Subtract([passenger_count],[total_amount],Precision.Decimal)),
    T11 = Table.AddColumn(T10,"DivideDefault",each Value.Divide([passenger_count],[total_amount])),
    T12 = Table.AddColumn(T11,"DivideDoublePrecision", each Value.Divide([passenger_count],[total_amount],Precision.Double)),
    T13 = Table.AddColumn(T12,"DivideDecimalPrecision", each Value.Divide([passenger_count],[total_amount],Precision.Decimal)),
    T14 = Table.AddColumn(T13,"CompareDefault",each Value.Compare([passenger_count],[total_amount])),
    T15 = Table.AddColumn(T14,"CompareDoublePrecision", each Value.Compare([passenger_count],[total_amount],Precision.Double)),
    T16 = Table.AddColumn(T15,"CompareDecimalPrecision", each Value.Compare([passenger_count],[total_amount],Precision.Decimal)),
    T17 = Table.AddColumn(T16,"ValueAs", each Value.As([passenger_count],type any)),
    T18 = Table.AddColumn(T17,"ValueReplaceType", each Value.ReplaceType([passenger_count],type number))
in 
    Table.FirstN(T18,1)