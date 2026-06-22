# Engineering Decisions Log

## Decision 1: Tool Selection — DuckDB over PostgreSQL

**Options considered:** PostgreSQL, SQLite, DuckDB, BigQuery  
**Chose:** DuckDB  
**Reasoning:**

- No server setup required (runs in-process)
- Reads CSVs directly without loading into memory
- Full SQL support for star schema design
- Single-file database (easy to share/reproduce)

**Trade-offs accepted:**

- No concurrent write access (not needed for this analysis)
- Less ecosystem than PostgreSQL

---

## Decision 2: Full Dataset vs Visualisations Subset

**Options considered:** visualisations/ (18 cols, 13MB) vs data/ (75 cols, 150MB)  
**Chose:** Full dataset  
**Reasoning:**

- Assignment requires testing hypotheses like H2 (superhost vs not)
- Full dataset has review_scores_rating (needed for Section 5)
- Full dataset has host_is_superhost (needed for H2)
- NLP requires actual review text (only in full version)

**Trade-offs accepted:**

- Larger download (~150MB vs 13MB)
- Slightly longer load time

---

## Decision 3: Calendar.csv.gz NOT Downloaded

**Options considered:** Download calendar (~400MB) vs skip  
**Chose:** Skip calendar data  
**Reasoning:**

- Time constraint (5-day deadline)
- Only needed for hypothesis H5 (weekend vs weekday pricing)
- Can acknowledge this limitation in final report

**Trade-offs accepted:**

- Cannot test hypothesis H5
- Documented in limitations section

---

## Decision 4: Read-only vs Read-write DuckDB Connection

**Options considered:** read_only=True (safer) vs normal (flexible)  
**Chose:** Normal connection  
**Reasoning:**

- Need to create views for clean price column
- Notebook 03 will need to write cleaned tables
- No concurrent access risk in single-user environment

**Trade-offs accepted:**

- Need to manage connection lifecycle carefully

---

## Decision 5: VARCHAR Price Handling

**Options considered:**

- A) Pre-clean price column before loading
- B) CAST in every query
- C) Create a view with cleaned price

**Chose:** Created `listings_clean` view  
**Reasoning:**

- View is reusable across all queries
- Original data preserved
- Cleaner code than repeated CAST statements

**Trade-offs accepted:**

- Slight query overhead (negligible for our dataset size)

---

## Decision 6: Property Type Standardization

**Options considered:**

- A) Keep 112 unique values
- B) Group into categories (Apartment, House, Hotel, etc.)

**Chose:** Option B (9 categories)

**Reasoning:**

- 112 values too granular for meaningful analysis
- Grouped using ILIKE pattern matching (apartment/flat/condo → Apartment)
- 9 categories cover ~99% of listings meaningfully

**Trade-offs accepted:**

- Loss of granularity (e.g., "luxury apartment" vs "studio apartment")
- Some listings may be mis-categorized at edges

---

## Decision 7: Price Outlier Thresholds

**Options considered:**

- A) Fixed thresholds ($5,000 high, $10 low)
- B) IQR method (Q3 + 1.5×IQR)
- C) Z-score method (mean ± 3×std)

**Chose:** Option A (fixed thresholds)

**Reasoning:**

- $5,000 is above realistic London luxury max
- $10 catches obvious data errors
- Simple to explain to non-technical stakeholders
- IQR would also work but harder to defend without statistics background

**Trade-offs accepted:**

- Not statistically rigorous
- 47 listings above $5K excluded (verified as all outliers)
- 7 listings below $10 excluded (all clearly errors)

---

## Decision 8: Cleaning Approach (Single-Pass vs Chained)

**Options considered:**

- A) Multiple chained CREATE OR REPLACE statements
- B) Single CREATE TABLE AS SELECT (one-pass)

**Chose:** Option B (single-pass, then split into readable cells)

**Reasoning:**

- Chained approach caused data loss (33K rows disappeared)
- Single-pass is auditable in one query
- Split into multiple cells for readability vs one massive cell

**Trade-offs accepted:**

- Slightly longer cells
- Must re-run entire cell if one transformation changes

---

## Decision 9: NULL Handling Strategy

**Strategy:** Preserve NULLs, don't impute or delete

**Rationale:**

- NULLs often represent valid business states:
  - New listings without price set
  - Hosts not yet evaluated for superhost
  - Listings without reviews yet
- Deleting would bias analysis toward established listings
- Imputation would invent fake data

**Implementation:**

- 32,977 NULL prices preserved with 'NO_PRICE' flag
- 50,520 NULL neighbourhoods resolved via neighbourhood_cleansed fallback
- NULL review scores preserved (new listings)
- NULL host_is_superhost → 'unknown' status (distinct from 'f')

**Trade-offs accepted:**

- Some analyses need explicit WHERE filters
- Summary statistics must handle NULL explicitly

---

## Decision 10: Modeling Trade-offs

### Star Schema vs Normalized (3NF)

**Chose:** Star schema  
**Reasoning:**

- Optimized for analytical queries (OLAP use case)
- Simpler joins (fewer tables to traverse)
- Standard for data warehousing (Snowflake, BigQuery use this)

**Trade-offs accepted:**

- Some data redundancy (neighbourhood name repeated in fact table)
- Not suitable for transactional workloads (OLTP)

### Surrogate Keys vs Natural Keys

**Chose:** Hybrid (natural for host, surrogate for location/property)  
**Reasoning:**

- host_id is already a stable natural key
- Neighbourhood names can be renamed/corrected (surrogate protects from this)
- Property combinations are derived (surrogate simplifies joins)

**Trade-offs accepted:**

- More complex ETL (must generate surrogate keys)
- Extra lookup needed for surrogate keys

### Slowly Changing Dimensions (SCD)

**Chose:** Type 1 SCD (overwrite)  
**Reasoning:**

- Single snapshot of data (no history to preserve)
- Simpler implementation
- Appropriate for this assessment

**Trade-offs accepted:**

- Cannot track historical changes to host/location/property attributes
- Would need Type 2 SCD for full history tracking

---
