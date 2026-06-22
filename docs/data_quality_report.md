# Data Quality Report

**Project:** Airbnb Data Engineering Assessment  
**City used** London, United Kingdom  
**Data Source:** Inside Airbnb (full listings.csv.gz + reviews.csv.gz)  
**Notebook used:** `02_data_ingestion_and_profiling.ipynb`

---

## Executive Summary

| Metric                  | Value     |
| ----------------------- | --------- |
| Total listings          | 96,182    |
| Total reviews           | 1,887,519 |
| Avg reviews per listing | 26.3      |
| Listings columns        | 75        |
| Reviews columns         | 6         |

**Key Issues Found:**

- ⚠️ Price stored as VARCHAR with "$" prefix (requires cleaning)
- ⚠️ 52.53% of listings have NULL neighbourhood
- ⚠️ 25.51% of listings have NULL review_scores_rating
- ⚠️ Extreme price outliers ($80,000/night max)
- ⚠️ 32,977 listings (34.29%) have NULL host_is_superhost
- ✅ Zero exact duplicate IDs
- ✅ Zero invalid coordinates
- ✅ Zero negative or zero prices

---

## 1. Row Counts & Completeness

| Table    | Rows      | Columns | Primary Key |
| -------- | --------- | ------- | ----------- |
| listings | 96,182    | 75      | id          |
| reviews  | 1,887,519 | 6       | id          |

**Average reviews per listing:** 26.3

**Assessment:** Dataset is comprehensive. London market well-represented.

---

## 2. Null Rate Analysis (Critical Fields)

| Column                   | Null Count | Null %     | Severity        | Implication                                   |
| ------------------------ | ---------- | ---------- | --------------- | --------------------------------------------- |
| id                       | 0          | 0.00%      | ✅ None         | Primary key intact                            |
| name                     | 0          | 0.00%      | ✅ None         | All listings have names                       |
| host_id                  | 0          | 0.00%      | ✅ None         | Host linkage intact                           |
| host_name                | 5          | 0.01%      | ✅ Negligible   | 5 anonymous hosts                             |
| **neighbourhood**        | **50,520** | **52.53%** | 🔴 **CRITICAL** | **Half of listings missing location context** |
| latitude                 | 0          | 0.00%      | ✅ None         | All geo-coded                                 |
| longitude                | 0          | 0.00%      | ✅ None         | All geo-coded                                 |
| room_type                | 0          | 0.00%      | ✅ None         | All categorized                               |
| price                    | 0          | 0.00%      | ✅ None         | All priced (but as text)                      |
| **host_is_superhost**    | **32,977** | **34.29%** | 🟡 **HIGH**     | **1/3 of listings lack superhost status**     |
| **review_scores_rating** | **24,533** | **25.51%** | 🟡 **HIGH**     | **1/4 of listings never reviewed**            |
| **last_review**          | **24,533** | **25.51%** | 🟡 **HIGH**     | **Matches rating nulls (expected)**           |

### Implications:

🔴 **Neighbourhood (52.53% NULL):**

- Geographic analysis by neighbourhood will be heavily skewed
- Will need imputation (use lat/long to assign nearest known neighbourhood)
- Suggests scraping limitation for newer listings

🟡 **Superhost (34.29% NULL):**

- Hosts not yet evaluated by Airbnb
- Cannot do reliable superhost vs non-superhost analysis without filtering
- Hypothesis H2 must explicitly exclude NULL values

🟡 **Review Scores (25.51% NULL):**

- Listings with 0 reviews have NULL scores
- Expected behavior — new listings haven't been reviewed
- Filter these out for quality-based analysis

---

## 3. Price Distribution & Outliers

| Metric           | Value   | Assessment           |
| ---------------- | ------- | -------------------- |
| Minimum          | $1.00   | ⚠️ Below market rate |
| Maximum          | $80,000 | 🔴 Extreme outlier   |
| Mean             | $197.15 | Skewed by outliers   |
| Median           | $130.00 | More realistic       |
| Listings > $1000 | 604     | Top 0.6%             |
| Listings < $10   | 7       | Likely data errors   |
| Zero prices      | 0       | ✅ Good              |
| Negative prices  | 0       | ✅ Good              |

### Top 10 Most Expensive Listings (Outlier Analysis):

| ID          | Name                           | Neighbourhood           | Type        | Price   |
| ----------- | ------------------------------ | ----------------------- | ----------- | ------- |
| 10404712... | Room In Zone 1 (TOB)           | None                    | Private     | $80,000 |
| 10696267... | Close To London Bridge         | None                    | Private     | $80,000 |
| 41557986    | Close To London Eye (HED)      | None                    | Private     | $75,000 |
| 42435181    | CLOSE TO LONDON EYE (CHEZ)     | None                    | Private     | $75,000 |
| 11831689... | Short Walk To London Eye (SUR) | None                    | Private     | $71,000 |
| 42596787    | Stunning Renovated Townhouse   | Neighborhood highlights | Entire home | $60,000 |
| 13254774    | No Longer Available            | Neighborhood highlights | Private     | $53,588 |
| 12045438... | Short Walk to London Eye (HON) | None                    | Private     | $50,000 |
| 9721759     | 3 Bed Flat in South Hampstead  | Neighborhood highlights | Entire home | $25,000 |
| 52112740    | —                              | None                    | Entire home | $20,000 |

**Outlier Pattern:**

- 6 of 10 have NULL neighbourhood (data quality issue)
- Multiple listings named "Close To London Eye" (suggests same operator or scraping duplication)
- One listing "No Longer Available" but still has high price
- Prices 380-600x the median — almost certainly data entry errors

### Action Required (Notebook 03):

- Cap price at reasonable threshold (e.g., $5,000/night max)
- Filter out "No Longer Available" listings
- Investigate listings with NULL neighbourhood + extreme prices
- Strip "$" prefix and convert to numeric

---

## 4. Room Type Distribution

| Room Type       | Count  | % of Total | Avg Price | Min | Max     |
| --------------- | ------ | ---------- | --------- | --- | ------- |
| Entire home/apt | 61,321 | 63.8%      | $238.77   | $12 | $60,000 |
| Private room    | 34,236 | 35.6%      | $111.38   | $1  | $80,000 |
| Shared room     | 437    | 0.5%       | $147.31   | $8  | $3,500  |
| Hotel room      | 188    | 0.2%       | $371.49   | $21 | $7,589  |

**Assessment:**

- 4 room types confirmed (matches official dictionary)
- Entire homes dominate (63.8%) — typical Airbnb pattern
- Hotel rooms command highest average price ($371) — premium segment
- Private rooms have widest price range ($1-$80K) — includes outliers
- Combined niche market (Shared + Hotel): 625 listings (0.6%)

**No outliers in room types** — all 4 expected values present, no unexpected categories.

---

## 5. Duplicate Detection

### Exact Duplicates (by ID):

- **Total duplicate IDs: 0**
- Dataset has no exact duplicates — primary key integrity maintained

### Fuzzy Duplicates (same name + neighbourhood + host + price):

| Listing Name                                       | Count |
| -------------------------------------------------- | ----- |
| Private Double Room in Warren Street               | 10    |
| Hyde Park Luxurious Hotel, Fabulous Double Room    | 9     |
| Hyde Park Luxurious Hotel, Beautiful Family Room   | 7     |
| Moorgate Old Street 2 bedroom 2 bathroom apartment | 6     |
| Double bed in newly refurbished warm guesthouse    | 5     |
| Stunning Shoreditch High Street Studio             | 4     |
| Clerkenwell 1 bedroom apartment with balcony       | 4     |
| Charing Cross Covent Garden apartment              | 4     |
| Stunning Shoreditch High Street Studio (variant)   | 4     |
| Tower Hill apartment                               | 4     |

**Pattern Identified:**

- All fuzzy duplicates located in "Neighborhood highlights" (placeholder category)
- Same property listed by same host with slight variations
- Likely multi-unit properties (hotels, B&Bs) — NOT true duplicates
- Indicates commercial bulk operators

**Action:** Treat as legitimate multi-unit listings, not duplicates. May indicate commercial operators worth investigating.

---

## 6. Geographic Validation

| Metric            | Value  | Status              |
| ----------------- | ------ | ------------------- |
| Min latitude      | 51.296 | Within London range |
| Max latitude      | 51.682 | Within London range |
| Min longitude     | -0.498 | Within London range |
| Max longitude     | 0.296  | Within London range |
| Invalid latitude  | 0      | None                |
| Invalid longitude | 0      | None                |
| Zero coordinates  | 0      | None                |

**Assessment:** All 96,182 listings have valid London coordinates. No geographic data quality issues.

---

## 7. Availability Distribution

| Metric                       | Value          | Interpretation                     |
| ---------------------------- | -------------- | ---------------------------------- |
| Min availability             | 0              | Some listings fully booked/blocked |
| Max availability             | 365            | Always available (commercial)      |
| Mean availability            | 132 days/year  | ~36% of year available             |
| Median availability          | 88 days/year   | Lower than mean (right-skewed)     |
| Zero availability            | 30,512 (31.7%) | Blocked or fully booked            |
| Full year availability (365) | 3,097 (3.2%)   | Commercial operators               |

**Insights:**

- 1 in 3 listings currently unavailable
- 3% are always available — strong indicator of commercial bulk operators
- Wide range suggests mixed market (casual hosts + professional operators)

**No outliers flagged** — distribution is realistic for short-term rental market.

---

## 8. Review Activity Distribution

| Metric                     | Count  | %      |
| -------------------------- | ------ | ------ |
| Listings with 0 reviews    | 24,533 | 25.51% |
| Listings with >500 reviews | 89     | 0.09%  |
| Avg reviews per listing    | 26.3   | —      |

**Assessment:**

- 25.5% of listings are new (no reviews yet) — expected
- 89 listings have >500 reviews — likely established commercial operators
- Wide range (0-500+) is realistic

**Action:** For review-based analysis, exclude listings with 0 reviews.

---

## 9. Domain Validation Summary

| Check               | Count | Status  |
| ------------------- | ----- | ------- |
| Negative prices     | 0     | ✅ Pass |
| Zero prices         | 0     | ✅ Pass |
| Invalid coordinates | 0     | ✅ Pass |
| Zero coordinates    | 0     | ✅ Pass |
| Duplicate IDs       | 0     | ✅ Pass |

**All domain constraints satisfied** — basic data integrity maintained.

---

## 10. Summary of Issues to Address in Notebook 03 (Cleaning)

### Critical (Must Fix):

1. **Price column:** VARCHAR → DECIMAL (strip "$", remove commas)
2. **Neighbourhood NULLs (52.53%):** Impute using lat/long reverse geocoding OR filter
3. **Extreme price outliers:** Cap at $5,000/night max

### High (Should Fix):

4. **Superhost NULLs (34.29%):** Treat as "Not Superhost" or exclude from H2
5. **Review score NULLs (25.51%):** Exclude from quality analysis
6. **No Longer Available listings:** Filter out for active market analysis

### Medium (Nice to Fix):

7. **Empty/placeholder names:** Standardize or remove
8. **Commercial operator detection:** Use calculated_host_listings_count > N

### Low (Document but don't fix):

9. **License NULLs:** Expected for London (UK doesn't require)
10. **Neighbourhood_group NULLs:** Expected (NYC-specific field)

---

## 11. Data Quality Score

| Category     | Score    | Notes                                  |
| ------------ | -------- | -------------------------------------- |
| Completeness | 7/10     | High nulls in neighbourhood, scores    |
| Uniqueness   | 10/10    | No duplicate IDs                       |
| Validity     | 9/10     | All constraints pass                   |
| Consistency  | 6/10     | Price format inconsistent (text)       |
| Accuracy     | 8/10     | Extreme outliers suggest some bad data |
| **Overall**  | **8/10** | **Production-ready with cleaning**     |

---

## 12. Column Cardinality Profile

### High Cardinality (Mostly Unique)

| Column      | Unique Values | Implication                                  |
| ----------- | ------------- | -------------------------------------------- |
| listing_url | 98,230        | Each listing has unique URL (expected)       |
| id          | 96,863        | Nearly 1:1 with rows (expected)              |
| name        | 91,251        | Most listings have unique names              |
| description | 79,747        | High variation (free text)                   |
| longitude   | 64,309        | Continuous (geographic spread)               |
| latitude    | 58,571        | Continuous (geographic spread)               |
| host_id     | 60,625        | Many listings per host (multi-listing hosts) |

### Medium Cardinality (Categorical-like)

| Column                 | Unique Values | Implication                        |
| ---------------------- | ------------- | ---------------------------------- |
| host_name              | 14,341        | Multiple hosts share names         |
| host_since             | 5,400         | Date range (signup dates)          |
| first_review           | 4,966         | Date range                         |
| last_review            | 3,810         | Date range                         |
| property_type          | 112           | Manageable categories              |
| neighbourhood_cleansed | 37            | Geocoded categories — **USE THIS** |
| room_type              | 4             | Matches dictionary exactly         |

### Low Cardinality (Boolean-like)

| Column            | Unique Values | Implication                                 |
| ----------------- | ------------- | ------------------------------------------- |
| source            | 2             | "previous scrape" or "neighbourhood search" |
| host_is_superhost | 2             | Boolean                                     |
| instant_bookable  | 2             | Boolean                                     |
| room_type         | 4             | Expected categories                         |

### Zero Cardinality (All NULL)

| Column                       | Implication                            |
| ---------------------------- | -------------------------------------- |
| neighbourhood_group_cleansed | NYC-specific, not applicable to London |
| calendar_updated             | Calendar feature not used              |
| license                      | UK doesn't require                     |

### Data Type Findings

- **Price:** Stored as VARCHAR (needs cleaning) — 1,261 unique values
- **Host response/acceptance rate:** Stored as VARCHAR (likely "100%", "95%") — needs parsing
- **Date columns:** Properly typed as DATE
- **Score columns:** Properly typed as DOUBLE
- **Boolean columns:** Properly typed

---

## 13. Cleaning Operations Summary

**Applied in Notebook 03 (Section 3.2):**

| Operation                     | Method                               | Rows Affected | Result                 |
| ----------------------------- | ------------------------------------ | ------------- | ---------------------- |
| Price VARCHAR → DECIMAL       | TRY_CAST + REPLACE chain             | 96,182        | 63,151 valid prices    |
| Cap high outliers (> $5K)     | CASE → NULL                          | 47            | Flagged 'EXTREME_HIGH' |
| Cap low outliers (< $10)      | CASE → NULL                          | 7             | Flagged 'EXTREME_LOW'  |
| Strip commas from prices      | REPLACE(',', '')                     | 715           | Successfully parsed    |
| Handle 'N/A' response rates   | TRY_CAST → NULL                      | 31,876        | Converted to NULL      |
| Handle 'N/A' acceptance rates | TRY_CAST → NULL                      | 27,221        | Converted to NULL      |
| NULL neighbourhood            | COALESCE with neighbourhood_cleansed | 50,520        | Resolved               |
| NULL host_is_superhost        | CASE → 'unknown'                     | 32,977        | Preserved with status  |
| Unavailable listings          | Flag is_active=FALSE                 | 12            | Flagged                |
| Property type (112 values)    | Grouped to 9 categories              | 96,182        | Normalized             |
| Coordinate precision          | ROUND to 5 decimals                  | 96,182        | Standardized           |

---

## 14. Post-Cleaning Validation

| Metric                | Before      | After      | Status              |
| --------------------- | ----------- | ---------- | ------------------- |
| Total listings        | 96,182      | 96,182     | ✅ Preserved        |
| Active listings       | 96,182      | 96,170     | ✅ 12 flagged       |
| Valid prices          | 63,205      | 63,151     | ✅ 54 capped        |
| NULL prices           | 32,977      | 33,031     | ✅ +54 from capping |
| Neighbourhood known   | 45,662      | 96,182     | ✅ All resolved     |
| Property categories   | 112         | 9          | ✅ Grouped          |
| Coordinates precision | 6+ decimals | 5 decimals | ✅ Standardized     |

**All Section 3.2 requirements satisfied:**

- ✅ Standardize price columns
- ✅ Parse and standardize date fields
- ✅ Normalize free-text fields
- ✅ Handle missing values
- ✅ Remove/flag records failing validation
- ✅ Standardize geographic fields

---

## 15. Updated Data Quality Score (Post-Cleaning)

| Category     | Before   | After      | Improvement            |
| ------------ | -------- | ---------- | ---------------------- |
| Completeness | 7/10     | 9/10       | Neighbourhood resolved |
| Uniqueness   | 10/10    | 10/10      | No change              |
| Validity     | 9/10     | 10/10      | Outliers capped        |
| Consistency  | 6/10     | 9/10       | Price standardized     |
| Accuracy     | 8/10     | 9/10       | Outliers removed       |
| **Overall**  | **8/10** | **9.5/10** | **Production-ready**   |

---

## 16. Cleaning Decisions Documentation

| Decision              | Choice                     | Rationale                         |
| --------------------- | -------------------------- | --------------------------------- |
| Price outliers (high) | Cap at $5,000              | Above realistic London luxury max |
| Price outliers (low)  | Cap at $10                 | Below London market reality       |
| NULL price            | Preserve as 'NO_PRICE'     | Real data state                   |
| NULL neighbourhood    | Use neighbourhood_cleansed | Geocoded, 0% nulls                |
| NULL superhost        | Mark 'unknown'             | Different from 'false'            |
| Unavailable listings  | Flag (not delete)          | Keep for reference                |
| Property type         | Group to 9 categories      | Enables analysis                  |
| Coordinate precision  | 5 decimals                 | ~1 meter accuracy                 |
