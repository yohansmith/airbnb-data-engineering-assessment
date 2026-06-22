-- fact_listings: Central fact table
-- One row per listing
-- Grain: listing_id
-- Foreign keys: host_id, location_id, property_id

CREATE TABLE fact_listings (
    listing_id BIGINT PRIMARY KEY,
    host_id BIGINT REFERENCES dim_host(host_id),
    location_id INTEGER REFERENCES dim_location(location_id),
    property_id INTEGER REFERENCES dim_property(property_id),
    price DECIMAL,
    price_flag VARCHAR,
    minimum_nights INTEGER,
    maximum_nights INTEGER,
    availability_365 INTEGER,
    number_of_reviews INTEGER,
    number_of_reviews_ltm INTEGER,
    reviews_per_month DOUBLE,
    review_scores_rating DOUBLE,
    review_scores_cleanliness DOUBLE,
    review_scores_location DOUBLE,
    review_scores_communication DOUBLE,
    review_scores_value DOUBLE,
    first_review DATE,
    last_review DATE,
    is_active BOOLEAN,
    instant_bookable BOOLEAN
);
