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
	improvement_surcharge double,
	total_amount double,
	payment_type int,
	trip_type int,
	congestion_surcharge double
);

CREATE TABLE NycTaxiDateData (
    RecordID int NOT NULL,
	lpep_pickup_time date NOT NULL,
	lpep_dropoff_time date NULL
);

CREATE TABLE TaxiZoneLookup (
    LocationID int,
	Borough string,
	Zone string,
	service_zone string
);
