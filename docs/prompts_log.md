# AI Prompts Log

This file tracks all the AI interactions I had during the assessment.

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
