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
