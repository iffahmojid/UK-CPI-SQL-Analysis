# UK CPI Inflation — SQL Analysis

Exploratory SQL analysis of UK Consumer Price Inflation data (1988–2024)
using the ONS MM23 dataset, implemented in SQLite.

This project was subsequently migrated from SQLite to PostgreSQL to demonstrate 
knowledge of production-grade relational database systems.

## Dataset
**Source:** Office for National Statistics (ONS) — Consumer Price Indices (MM23)  
**Coverage:** Annual UK inflation rates, 1988–2024  
**Series used:**

| Column | ONS Code | Description |
|---|---|---|
| cpi_all_items | D7G7 | CPI All Items Annual Rate (%) |
| cpi_food | D7BT | CPI Food & Non-Alcoholic Beverages (%) |
| cpi_alcohol_tobacco | D7BU | CPI Alcohol & Tobacco (%) |
| cpi_energy | D7CA | CPI Electricity, Gas & Fuels (%) |
| cpi_transport | D7CE | CPI Transport (%) |
| rpi_all_items | CZBH | RPI All Items Annual Rate (%) |

## Data Pipeline
Raw ONS CSV (4,054 columns) → cleaned via Python/pandas → imported into SQLite

## SQL Queries
Eight queries demonstrating intermediate SQL proficiency:

1. **Basic filtering** — years where headline CPI exceeded 5%
2. **Aggregation** — average CPI by decade using GROUP BY
3. **CASE WHEN** — classifying each year as Below Target / On Target / Elevated / Crisis
4. **Window function (LAG)** — year-on-year change in headline CPI
5. **Window function (rolling avg)** — 5-year rolling average of CPI
6. **Subquery** — years where food inflation exceeded the all-time CPI average
7. **CTE + RANK** — top 5 years of energy price inflation
8. **Multi-column comparison** — RPI vs CPI divergence by year

## Key Findings
- 2022 recorded the highest headline CPI in the dataset at 9.1%, with the
  largest single-year acceleration of +6.5pp (2021→2022), driven by the
  post-pandemic cost of living crisis
- The 1990s saw the sharpest sustained disinflation in the dataset, with CPI
  falling from 7.5% in 1991 to 1.3% by 1999 — averaging just 3.3% across
  the decade versus 5.25% in the 1980s
- Energy inflation peaked in 2017 at 99.1%, followed by 2012 at 98.8% —
  both periods coinciding with global commodity price shocks
- Food inflation ran above the long-run CPI average in every single year
  of the dataset, with the largest premium recorded in 2013 (+95.9pp above
  headline CPI)
- CPI and RPI diverged most sharply in 2009, when RPI turned negative
  (-0.5%) while CPI remained positive at 2.2% — reflecting the different
  treatment of housing costs (mortgage interest) between the two measures
- The 2000s were the most stable decade for inflation, averaging just 1.86%
  per year — the only decade to average below the Bank of England's 2% target
- 2015 was the only year in the dataset where CPI was exactly 0.0%,
  classified as "Below Target" — reflecting the deflationary pressures
  of falling oil prices and weak global demand that year

## Inflation Regime Classification (CASE WHEN Results)
| Regime | Years | Count |
|---|---|---|
| Below Target (<2%) | 1997–2004, 2014–2016, 2019–2021, 2024 | 13 |
| On Target (2–3%) | 1993–1996, 2005–2007, 2009, 2012–2013, 2018, 2021 | 10 |
| Elevated (3–6%) | 1989, 1992, 2008, 2010–2011, 2025 | 7 |
| Crisis (>6%) | 1990–1991, 2022–2023 | 4 |

## Tools
SQLite | Python 3 | pandas | VSCode

## Files
| File | Description |
|---|---|
| `cpi_clean.csv` | Cleaned ONS data (7 columns, 37 annual observations) |
| `prepare_cpi.py` | Python script to clean and reshape raw ONS MM23 CSV |
| `sql.sql` | All 8 SQL queries with comments |
| `test.db` | SQLite database containing the cpi_annual table |

## How to Reproduce
1. Download `mm23.csv` from [ONS Consumer Price Indices](https://www.ons.gov.uk/economy/inflationandpriceindices/datasets/consumerpriceindices/current)
2. Run `prepare_cpi.py` to generate `cpi_clean.csv`
3. Import into SQLite: `sqlite3 test.db` → `.mode csv` → `.import cpi_clean.csv cpi_annual`
4. Run queries from `sql.sql` using the SQLite VSCode extension (alexcvzz)
