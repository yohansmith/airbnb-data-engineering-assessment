# AI Prompts Log

This file tracks all the meaningful AI interactions I had during the assessment.

---

### Prompt 1: Initial Problem Sort Outing

**Asked to:** MiniMax
**What I asked:** "What AI should I use for this Data Engineer Intern
assessment? I'm not an absolute beginner with just one week to spear as a deadline. Tabulate and compare your findings"
**What I got:** Recommended hybrid strategy using Claude free model or local AI tools since currently using a cloud LLM running in Ollama as it was free and not will not limit usage like Claude or other AI tools. Also recommended to use Github Copilot for issues related to code for ease.
**Did it work?** Yes. I adopted the approach with the use of the model - minimax-m3:cloud within Ollama for assisting the workflow while using Claude and Github Copilot as well.

### Prompt 2: Project Structure & Folder Organization

**Asked to:** MiniMax
**What I asked:** "What folder structure should I use for this data engineering
project? I need a professional setup for GitHub submission."
**What I got:** Detailed folder structure with:

- data/ (raw and processed)
- notebooks/ (numbered Jupyter notebooks)
- src/ (reusable Python modules)
- sql/ (schema and analytics)
- reports/ (final PDF and figures)
- docs/ (AI disclosure, decisions log, prompts log)
- tests/ (unit tests)
- dashboards/ (optional Streamlit)

**Did it work?** Yes. Created exactly this structure
**Modified?** Added .gitkeep placeholder files so empty folders get tracked by Git

### Prompt 3: Tools & Tech Stack Selection

**Asked to:** MiniMax
**What I asked:** "What tools should I use? My plan is to use VS Code as the environment so that I could use Jupter Notebook extension for notebooks and easy for commiting to the repo. Is this the right tools to use? Should I use Jupyter or Google Colab? Also give the relevant tool for handling database and other list other libraries we would use"
**What I got:** Confirmed VS Code + Jupyter (not Colab) for professional appearance, DuckDB over PostgreSQL/SQLite for simplicity, scikit-learn for ML, matplotlib for charts
**Did it work?** Yes. The current stack works perfectly for my skill level
**Modified?** Used free tools only, no paid services

### Prompt 4: City Selection for Analysis

**Asked to:** MiniMax + Claude.ai
**What I asked:** "Which city should I analyze? London, NYC, Amsterdam, or Asheville?"
**What I got:** London recommended (~80,000 listings, English reviews,
100+ neighborhoods, well-documented)
**Did it work?** Yes. London data is clean and large enough for statistics
**Modified?** Verified URL paths work before downloading

### Prompt 5: Git Setup & GitHub Workflow

**Asked to:** MiniMax
**What I asked:** "Should I commit CSV files to Git since they are not that large in size? Do I need to set up the GitHub repo?"
**What I got:** NO to CSVs (too large), YES to code and notebooks. Use .gitignore
to exclude data/, venv/, **pycache**/
**Did it work?** Yes, git status shows clean repo, CSVs properly ignored
**Modified?** Made repository private until assessment is complete

### Prompt 6: DuckDB Loading Strategy

**Asked to:** MiniMax
**What I asked:** "How do I load CSVs into DuckDB without memory issues?"
**What I got:** Use read_csv_auto() function, creates SQL tables directly
**Did it work?** Yes
**Modified?** Adjusted paths to use ../data/ for correct project root location

### Prompt 7: Path Resolution Issue

**Asked to:** MiniMax
**What I asked:** "Why is data folder nested inside notebooks?"
**What I got:** Identified relative path issue which needed to be updated as ../data/ prefix
**Did it work?** Yes. Fixed by updating paths and moving files
**Modified?** Documented as engineering decision for the report

### Prompt 8: Price Column Type Discovery

**Asked to:** MiniMax
**What I asked:** "Why does AVG(price) fail with binder error?"
**Got:** Explanation that price is VARCHAR due to "$" prefix
**Did it work?** Yes. Used CAST(REPLACE()) pattern
**Modified:** Created reusable `listings_clean` view

### Prompt 9: View Creation Failure

**Asked to:** MiniMax  
**What I asked:** "Why can't I CREATE VIEW in DuckDB?"
**Got:** Database was opened in read_only mode
**Did it work?** Yes. I reconnected without read_only=True
**Modified:** Now using normal connection throughout

### Prompt 10: Duplicate Detection Strategy

**Asked to:** MiniMax
**What I asked:** "How do I detect fuzzy duplicates?"
**Got:** Query that groups by name+neighbourhood+price+host
**Did it work?** Yes. Found 10 groups of suspected duplicates
**Modified:** Documented that these are likely multi-unit commercial properties, not true duplicates

---

### Prompt 11: TRY_CAST vs CAST Decision

**Asked to:** MiniMax
**What I asked:** "Why does CAST fail on host_response_rate with 'N/A' values?"
**Got:** Explanation that TRY_CAST returns NULL instead of erroring
**Did it work?** Yes, used TRY_CAST throughout cleaning
**Modified?** All transformations now use TRY_CAST for safety

### Prompt 12: Data Loss Debugging

**Asked to:** MiniMax
**What I asked:** "Why did listings_final only have 63,151 rows instead of 96,182?"
**Got:** Diagnosed that 32,977 listings had NULL price in source data; our capping added 54 more
**Did it work?** Yes, rebuilt with explicit NULL handling and NO_PRICE flag
**Modified?** Added validation cell to match counts against quality report

### Prompt 13: Property Type Categorization

**Asked to:** MiniMax
**What I asked:** "How to group 112 property types into meaningful categories?"
**Got:** CASE statement with ILIKE pattern matching for apartment/house/hotel/etc.
**Did it work?** Yes, reduced to 9 categories covering all listings
**Modified?** Used ELSE 'Other' for edge cases

### Prompt 14: Cleaning Cell Structure

**Asked to:** MiniMax
**What I asked:** "Can we split the cleaning into multiple cells for readability?"
**Got:** Yes, break into 8-10 cells, one per task
**Did it work?** Yes, much easier to read and debug
**Modified?** Each cell has markdown explanation above code

### Prompt 15: NULL Price Decision

**Asked to:** MiniMax
**What I asked:** "Should we delete listings with NULL price or keep them?"
**Got:** Keep NULLs, filter in analysis — NULL is valid business state
**Did it work?** Yes, preserved 32,977 NULLs with NO_PRICE flag
**Modified?** Documented decision in markdown cell

### Prompt 16: Threshold Justification

**Asked to:** MiniMax
**What I asked:** "Why $5,000 and $10 thresholds? Are these arbitrary?"
**Got:** Acknowledged they're judgment calls, not statistical
**Did it work?** Yes, documented as engineering decision with rationale
**Modified?** Added to decisions_log.md

### Prompt 17: EDA Chart Selection Strategy

**Asked to:** MiniMax
**What I asked:** "How many charts do I need for Section 4 EDA?"
**Got:** Recommended 12-15 charts covering all 5 subsections
**Did it work?** Yes, produced 13 charts total
**Modified?** Added business interpretation markdown cells after each chart

### Prompt 18: Availability Distribution Interpretation

**Asked to:** MiniMax
**What I asked:** "Why is the availability distribution bimodal?"
**Got:** Explained 0 = booked/blocked, 365 = commercial operators, middle = rare
**Did it work?** Yes, clear business interpretation
**Modified?** Added action items for hosts, investors, platform

### Prompt 19: Superhost Pricing Anomaly

**Asked to:** MiniMax
**What I asked:** "Why don't superhosts charge more?"
**Got:** Explained superhost = quality signal, not price signal
**Did it work?** Yes, clarified that quality ≠ pricing power
**Modified?** Added insight about platform incentive design

### Prompt 20: Market Concentration Metric

**Asked to:** MiniMax
**What I asked:** "How to measure market concentration by host category?"
**Got:** GROUP BY calculated_host_listings_count with CASE statement
**Did it work?** Yes, created 4-tier host segmentation
**Modified?** Added interpretation that casual vs commercial is near-even split

### Prompt 21: Review Sub-Dimension Comparison

**Asked to:** MiniMax
**What I asked:** "How to interpret which sub-dimension is weakest?"
**Got:** Look for largest gap between best and worst scores
**Did it work?** Yes, Value (4.62) and Cleanliness (4.65) flagged as weak
**Modified?** Added actionable insights for each weakness

---
