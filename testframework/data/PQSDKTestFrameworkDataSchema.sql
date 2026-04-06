-- Note: Columns defined as 'double' in the taxi data contain values rounded to
-- two decimal places. Map 'double' to the appropriate floating-point or decimal
-- type in your data source (e.g., FLOAT, DOUBLE, REAL, DECIMAL(10,2), NUMBER).
-- Similarly, map 'int' to INTEGER/INT, 'boolean' to BOOLEAN/BIT, 'timestamp' to
-- DATETIME/TIMESTAMP, 'date' to DATE, 'string' to VARCHAR/NVARCHAR/TEXT, and
-- 'decimal(p,s)' to DECIMAL/NUMBER with the specified precision and scale as
-- supported by your data source.

CREATE TABLE NycTaxiData(
	RecordID int,
	VendorID int,
	lpep_pickup_datetime timestamp,
	lpep_dropoff_datetime timestamp,
	store_and_fwd_flag boolean,
	RatecodeID int,
	PULocationID int,
	DOLocationID int,
	passenger_count int,
	trip_distance double,
	fare_amount double,
	extra double,
	mta_tax double,
	tip_amount double,
	tolls_amount double,
	ehail_fee double,
	improvement_surcharge double,
	total_amount double,
	payment_type int,
	trip_type int,
	congestion_surcharge double
);

CREATE TABLE NycTaxiDateData (
    RecordID int NOT NULL,
	lpep_pickup_date date NOT NULL,
	lpep_dropoff_date date NOT NULL
);

CREATE TABLE TaxiZoneLookup (
    LocationID int,
	Borough string,
	Zone string,
	service_zone string
);

CREATE TABLE misc_table (
	DATETIMEFIELD timestamp,
	BOOLEANFIELD boolean,
	BIGNUMERICFIELD decimal(38,18),
	NUMERICFIELD decimal(12,6),
	INTEGERFIELD int,
	STRINGFIELD string
);
