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
- ✅ Dataset has no exact duplicates — primary key integrity maintained

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

| Metric            | Value  | Status                 |
| ----------------- | ------ | ---------------------- |
| Min latitude      | 51.296 | ✅ Within London range |
| Max latitude      | 51.682 | ✅ Within London range |
| Min longitude     | -0.498 | ✅ Within London range |
| Max longitude     | 0.296  | ✅ Within London range |
| Invalid latitude  | 0      | ✅ None                |
| Invalid longitude | 0      | ✅ None                |
| Zero coordinates  | 0      | ✅ None                |

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

_Report generated from Notebook 02 outputs. All numbers verified against live DuckDB queries._
