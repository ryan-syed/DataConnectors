# PQ SDK Test Framework - Test Data

The test data used for PQ SDK Test framework is a modified version of the **Taxi & Limousine Comission (TLC) green trip
record data** and the **Taxi Zone Lookup table**. The details of the data could be found on the
[TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) page on the NYC Taxi & Limousine
Commission website.

The modified dataset is open for anyone to use under the [CDLA-Permissive-2.0 license](https://cdla.dev/permissive-2-0/).

## PQ SDK Test Framework - Test Data Details:

The PQ SDK Test Framework dataset contains the below files:

- **nyc_taxi_tripdata.csv** file with 10000 rows sampled from the February 2023 green trip data
- **nyc_taxi_trip_date_data.csv** file with 10000 rows containing record identifier and two date columns processed from
  the February 2023 green trip data
- **taxi+\_zone_lookup.csv** file which contains 265 rows from the taxi zone lookup table
- **PQSDKTestFrameworkDataSchema.sql** file contains the schema for NyxTaxiGreen and TaxiZoneLookup table

## PQ SDK Test Framework - Data Types and Precision

The schema in **PQSDKTestFrameworkDataSchema.sql** uses generic type names (`int`, `double`, `boolean`, `timestamp`,
`date`, `string`) that should be mapped to the equivalent types in your data source. In particular:

| Schema Type | Description | Example Mappings |
|-------------|-------------|------------------|
| `int` | Whole numbers | INTEGER, INT, NUMBER(38,0) |
| `double` | Floating-point values rounded to **two decimal places** in the taxi data | FLOAT, DOUBLE, REAL, DECIMAL(10,2), NUMBER |
| `boolean` | True/false flags | BOOLEAN, BIT |
| `timestamp` | Date and time | DATETIME, TIMESTAMP, TIMESTAMP_NTZ |
| `date` | Date only | DATE |
| `string` | Variable-length text | VARCHAR, NVARCHAR, TEXT |

> **Note:** All `double` columns in the **NycTaxiData** table (e.g., `trip_distance`, `fare_amount`, `total_amount`)
> contain values with at most two decimal places. When choosing a data source type, either a floating-point type
> (FLOAT/DOUBLE) or a fixed-precision decimal type (e.g., DECIMAL(10,2)) will work.

## PQ SDK Test Framework - Test Data Loading

The PQ SDK Test Framework dataset needs to be loaded to the datasource for your extension connector before running the
PQ SDK Testframework Test Suites. The data is provided in convenient csv format so that it can be easily be loaded to
any datasource. The **nyc_taxi_tripdata.csv**, **nyc_taxi_trip_date_data.csv** and **taxi+\_zone_lookup.csv** files
should be respectively loaded into **NycTaxiData**, **NycTaxiDateData** and **TaxiZoneLookup** tables as per the schema
specified in the **PQSDKTestFrameworkDataSchema.sql** file.
