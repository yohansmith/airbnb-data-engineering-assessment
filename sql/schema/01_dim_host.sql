-- dim_host: Host dimension table
-- One row per unique host
-- Grain: host_id

CREATE TABLE dim_host (
    host_id BIGINT PRIMARY KEY,
    host_name VARCHAR,
    host_since DATE,
    host_location VARCHAR,
    host_is_superhost BOOLEAN,
    superhost_status VARCHAR,  -- 't', 'f', 'unknown'
    host_response_rate INTEGER,  -- 0-100
    host_acceptance_rate INTEGER,  -- 0-100
    calculated_host_listings_count BIGINT
);
