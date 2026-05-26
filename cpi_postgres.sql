-- creates table with all the columns, and respective digits/decimal places--
CREATE TABLE cpi_annual (
    period INTEGER,
    cpi_all_items NUMERIC(5,2),
    cpi_food NUMERIC(5,2),
    cpi_alcohol_tobacco NUMERIC(5,2),
    cpi_energy NUMERIC(5,2),
    cpi_transport NUMERIC(5,2),
    rpi_all_items NUMERIC(5,2)
);
-- copy data from csv from other folder, seperates by , and notifies of header -- 
COPY cpi_annual
FROM '/tmp/cpi_clean.csv'
DELIMITER ','
CSV HEADER;
-- double check data has come through correctly -- 
SELECT * FROM cpi_annual LIMIT 5;

-- 1. BASIC SELECT & FILTER

SELECT period, cpi_all_items
FROM cpi_annual
WHERE cpi_all_items > 5
ORDER BY cpi_all_items DESC;

-- 2. AGGREGATION — GROUP BY & AVG
-- Average CPI by decade — via /10. Mean of the decade, then round to 2dp

SELECT
    (period / 10) * 10 AS decade,
    ROUND(AVG(cpi_all_items), 2) AS avg_cpi,
    ROUND(AVG(cpi_food), 2)      AS avg_food_cpi,
    ROUND(AVG(cpi_energy), 2)    AS avg_energy_cpi
FROM cpi_annual
WHERE cpi_all_items IS NOT NULL
GROUP BY decade
ORDER BY decade;

-- 3. CASE WHEN — Categorise inflation environment essentially in if,elif, else
-- Label each year as Low / Moderate / High / Crisis inflation

SELECT
    period,
    cpi_all_items,
    CASE
        WHEN cpi_all_items < 2  THEN 'Below Target'
        WHEN cpi_all_items <= 3 THEN 'On Target'
        WHEN cpi_all_items <= 6 THEN 'Elevated'
        ELSE 'Crisis'
    END AS inflation_regime
FROM cpi_annual
WHERE cpi_all_items IS NOT NULL
ORDER BY period;

-- 4. WINDOW FUNCTION — Year-on-year change (LAG)
-- Order by period to get previous years cpi, and then lag by 1 using OVER to make new prev year col
-- then another OVER to calc difference, excluding 1st year
SELECT
    period,
    cpi_all_items,
    LAG(cpi_all_items, 1) OVER (ORDER BY period) AS prev_year_cpi,
    ROUND(
        cpi_all_items - LAG(cpi_all_items, 1) OVER (ORDER BY period),
    2) AS yoy_change
FROM cpi_annual
WHERE cpi_all_items IS NOT NULL;


-- 5. WINDOW FUNCTION — Running average (moving average)
-- 5-year rolling average of headline CPI
-- average the row and the 4 before it, and then name it as rolling 5 year

SELECT
    period,
    cpi_all_items,
    ROUND(
        AVG(cpi_all_items) OVER (
            ORDER BY period
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ),
    2) AS rolling_5yr_avg
FROM cpi_annual
WHERE cpi_all_items IS NOT NULL;

-- 6. SUBQUERY — Find years where food inflation > headline CPI
-- calc difference between cpi_food and cpi_all items, round
-- subquery finding where food cpi > normal cpi

SELECT period, cpi_all_items, cpi_food,
       ROUND(cpi_food - cpi_all_items, 2) AS food_premium
FROM cpi_annual
WHERE cpi_food > (SELECT AVG(cpi_all_items) FROM cpi_annual)
  AND cpi_food IS NOT NULL
ORDER BY food_premium DESC;

-- 7. CTE (Common Table Expression) — Clean, readable multi-step logic
-- Find the top 5 years of energy price inflation
-- create temp table, with ranked_energy and then select 2 COLUMNS
-- over to create new ranking column of highest inflation

WITH ranked_energy AS (
    SELECT
        period,
        cpi_energy,
        RANK() OVER (ORDER BY cpi_energy DESC) AS energy_rank
    FROM cpi_annual
    WHERE cpi_energy IS NOT NULL
)
SELECT period, cpi_energy, energy_rank
FROM ranked_energy
WHERE energy_rank <= 5;

-- 8. MULTI-COLUMN COMPARISON — CPI vs RPI divergence
-- RPI is an older measure — when do they diverge most?
-- rpi - cpi, rounded to 2dp then ordered by absolute value descending
SELECT
    period,
    cpi_all_items,
    rpi_all_items,
    ROUND(rpi_all_items - cpi_all_items, 2) AS rpi_cpi_gap
FROM cpi_annual
WHERE cpi_all_items IS NOT NULL
AND rpi_all_items IS NOT NULL
ORDER BY ABS(rpi_all_items - cpi_all_items) DESC
LIMIT 10;



