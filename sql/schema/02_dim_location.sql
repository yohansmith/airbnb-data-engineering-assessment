-- dim_location: Location dimension table
-- One row per unique neighbourhood (37 for London)
-- Grain: neighbourhood_cleansed
-- Surrogate key: location_id

CREATE TABLE dim_location (
    location_id INTEGER PRIMARY KEY,
    neighbourhood VARCHAR,
    avg_latitude DOUBLE,
    avg_longitude DOUBLE,
    listing_count BIGINT
);
