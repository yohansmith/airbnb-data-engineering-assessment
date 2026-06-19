# Data Quality Report

## Dataset: London, United Kingdom

## Source: Inside Airbnb (http://insideairbnb.com/get-the-data/)

## Snapshot Date: September 6, 2024

---

## 1. Files Downloaded

| File         | Size    | Rows      | Purpose           |
| ------------ | ------- | --------- | ----------------- |
| listings.csv | 13.7 MB | 96,182    | Core listing data |
| reviews.csv  | 40.8 MB | 1,887,519 | Guest reviews     |

---

## 2. Schema Overview

### Listings Table (18 columns)

| Column                         | Type    | Description                             |
| ------------------------------ | ------- | --------------------------------------- |
| id                             | BIGINT  | Unique listing identifier (Primary Key) |
| name                           | VARCHAR | Listing title                           |
| host_id                        | BIGINT  | Host identifier (Foreign Key concept)   |
| host_name                      | VARCHAR | Host's display name                     |
| neighbourhood_group            | VARCHAR | (All None for London)                   |
| neighbourhood                  | VARCHAR | Specific area in London                 |
| latitude                       | DOUBLE  | Geographic coordinate                   |
| longitude                      | DOUBLE  | Geographic coordinate                   |
| room_type                      | VARCHAR | Entire home, Private room, etc.         |
| price                          | BIGINT  | Nightly price in GBP                    |
| minimum_nights                 | BIGINT  | Minimum stay requirement                |
| number_of_reviews              | BIGINT  | Total reviews received                  |
| last_review                    | DATE    | Date of most recent review              |
| reviews_per_month              | DOUBLE  | Average review frequency                |
| calculated_host_listings_count | BIGINT  | Listings per host                       |
| availability_365               | BIGINT  | Days available per year                 |
| number_of_reviews_ltm          | BIGINT  | Reviews in last 12 months               |
| license                        | VARCHAR | (All None for London)                   |

### Reviews Table

(Listed after profiling)

---

## 3. Initial Observations

- `neighbourhood_group` is entirely NULL for London (NYC-specific field)
- `license` is entirely NULL (likely not required in UK)
- `price` is already numeric (cleaner than typical Inside Airbnb format)
- `last_review` dates range from recent to historical
- 96,182 listings suggests comprehensive coverage of London market

---

## 4. Pending Analysis (Day 2)

- Null counts per column (detailed)
- Duplicate listings detection
- Price outlier detection
- Geographic coordinate validation
- Date range validation
- Reviews table schema
