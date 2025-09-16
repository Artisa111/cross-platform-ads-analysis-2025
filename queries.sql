-- cross_platform_ad_campaign_2025/queries.sql
--
-- This SQL script accompanies the *Cross‑Platform Advertising Campaign Performance Analysis 2025* project.
-- It defines a table structure for storing advertising data, demonstrates how to load
-- the sample dataset, and provides several queries for calculating key performance
-- indicators (KPIs) and performing month‑over‑month trend analysis.  The script
-- assumes a PostgreSQL environment but can be adapted to other SQL dialects with
-- minimal changes.

/*
 * 1. Create table for daily advertising data
 *
 * Each row represents aggregated metrics for one platform on a given day.
 * Columns:
 *  - date:        the calendar day (DATE)
 *  - platform:    the advertising channel (e.g. 'Facebook' or 'Google')
 *  - impressions: number of times ads were displayed (INTEGER)
 *  - clicks:      number of clicks on ads (INTEGER)
 *  - cost:        total spend for the day in the platform’s currency (NUMERIC)
 *  - conversions: number of conversions or user actions (INTEGER)
 *  - revenue:     revenue attributed to those conversions (NUMERIC)
 */

DROP TABLE IF EXISTS ads_data;

CREATE TABLE ads_data (
  date         DATE NOT NULL,
  platform     VARCHAR(50) NOT NULL,
  impressions  INTEGER NOT NULL,
  clicks       INTEGER NOT NULL,
  cost         NUMERIC(12,2) NOT NULL,
  conversions  INTEGER NOT NULL,
  revenue      NUMERIC(12,2) NOT NULL
);

--
-- 2. Loading data
--
-- If you have superuser privileges, you can load the CSV file exported with this
-- project using the COPY command.  Adjust the file path to point to the
-- location of `ads_data.csv` on your system.
--
-- COPY ads_data
--   FROM '/absolute/path/to/ads_data.csv'
--   WITH (FORMAT csv, HEADER true);
--
-- Alternatively, use a client‑side tool such as psql’s \copy or import the
-- data via your favorite PostgreSQL interface.


/*
 * 3. Calculate aggregated KPIs per platform and overall
 *
 * This query returns the total impressions, clicks, cost, revenue and the key
 * metrics CTR, CPC, CPM and ROMI for each platform.  The final row
 * (using GROUPING SETS) aggregates across all platforms to provide overall
 * performance.
 */

SELECT COALESCE(platform, 'ALL_PLATFORMS') AS platform,
       SUM(impressions) AS total_impressions,
       SUM(clicks) AS total_clicks,
       SUM(cost) AS total_cost,
       SUM(revenue) AS total_revenue,
       (SUM(clicks)::NUMERIC / NULLIF(SUM(impressions),0))        AS ctr,
       (SUM(cost) / NULLIF(SUM(clicks),0))                        AS cpc,
       (SUM(cost) / NULLIF(SUM(impressions),0)) * 1000            AS cpm,
       ((SUM(revenue) - SUM(cost)) / NULLIF(SUM(cost),0))         AS romi
FROM ads_data
GROUP BY GROUPING SETS ((platform), ());

/*
 * 4. Aggregate KPIs by month and platform
 *
 * This query groups data by calendar month and platform, computing the same
 * metrics as above.  It is useful for analysing seasonal patterns and
 * comparing performance across channels.
 */

SELECT date_trunc('month', date) AS month,
       platform,
       SUM(impressions) AS impressions,
       SUM(clicks) AS clicks,
       SUM(cost) AS cost,
       SUM(revenue) AS revenue,
       (SUM(clicks)::NUMERIC / NULLIF(SUM(impressions),0))        AS ctr,
       (SUM(cost) / NULLIF(SUM(clicks),0))                        AS cpc,
       (SUM(cost) / NULLIF(SUM(impressions),0)) * 1000            AS cpm,
       ((SUM(revenue) - SUM(cost)) / NULLIF(SUM(cost),0))         AS romi
FROM ads_data
GROUP BY month, platform
ORDER BY month, platform;

/*
 * 5. Month‑over‑month (MoM) trend analysis
 *
 * The Common Table Expression (CTE) `monthly` aggregates metrics across all
 * platforms for each month.  The outer query compares each month to the
 * previous month using the LAG window function to compute percentage change
 * for impressions and each KPI.  This helps identify improving or declining
 * performance over time.
 */

WITH monthly AS (
    SELECT
        date_trunc('month', date)::DATE AS month,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(cost) AS cost,
        SUM(revenue) AS revenue,
        (SUM(clicks)::NUMERIC / NULLIF(SUM(impressions),0))        AS ctr,
        (SUM(cost) / NULLIF(SUM(clicks),0))                        AS cpc,
        (SUM(cost) / NULLIF(SUM(impressions),0)) * 1000            AS cpm,
        ((SUM(revenue) - SUM(cost)) / NULLIF(SUM(cost),0))         AS romi
    FROM ads_data
    GROUP BY month
)
SELECT
    month,
    impressions,
    clicks,
    cost,
    revenue,
    ctr,
    cpc,
    cpm,
    romi,
    ROUND((impressions - LAG(impressions) OVER (ORDER BY month))
          / NULLIF(LAG(impressions) OVER (ORDER BY month),0) * 100, 2) AS impressions_mom_change_pct,
    ROUND((ctr - LAG(ctr) OVER (ORDER BY month))
          / NULLIF(LAG(ctr) OVER (ORDER BY month),0) * 100, 2) AS ctr_mom_change_pct,
    ROUND((cpc - LAG(cpc) OVER (ORDER BY month))
          / NULLIF(LAG(cpc) OVER (ORDER BY month),0) * 100, 2) AS cpc_mom_change_pct,
    ROUND((cpm - LAG(cpm) OVER (ORDER BY month))
          / NULLIF(LAG(cpm) OVER (ORDER BY month),0) * 100, 2) AS cpm_mom_change_pct,
    ROUND((romi - LAG(romi) OVER (ORDER BY month))
          / NULLIF(LAG(romi) OVER (ORDER BY month),0) * 100, 2) AS romi_mom_change_pct
FROM monthly
ORDER BY month;

/*
 * 6. Identify top performing months by ROMI with minimum spend
 *
 * This example query identifies months where the total spend (cost) exceeds a
 * specified threshold and orders the results by ROMI in descending order.
 * Adjust the threshold according to your organisation’s definition of a
 * material advertising investment.
 */

-- Set threshold for minimum monthly spend
\set spend_threshold 100

WITH monthly_platform AS (
    SELECT
        date_trunc('month', date)::DATE AS month,
        platform,
        SUM(cost) AS cost,
        ((SUM(revenue) - SUM(cost)) / NULLIF(SUM(cost),0)) AS romi
    FROM ads_data
    GROUP BY month, platform
)
SELECT month, platform, cost, romi
FROM monthly_platform
WHERE cost > :spend_threshold
ORDER BY romi DESC
LIMIT 10;
