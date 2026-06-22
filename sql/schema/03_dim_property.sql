-- dim_property: Property dimension table
-- One row per unique (room_type, property_category) combination
-- Grain: room_type + property_category
-- Surrogate key: property_id

CREATE TABLE dim_property (
    property_id INTEGER PRIMARY KEY,
    room_type VARCHAR,
    property_category VARCHAR,
    listing_count BIGINT
);
