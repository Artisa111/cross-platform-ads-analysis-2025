-- cross_platform_ad_campaign_2025/queries.sql
--
-- This SQL script accompanies the *Cross‑Platform Advertising Campaign Performance Analysis 2025* project.
-- It defines a table structure for storing advertising data, demonstrates how to load
-- the sample dataset, and provides several queries for calculating key performance
-- indicators (KPIs) and performing month‑over‑month trend analysis.  The script
-- assumes a PostgreSQL environment but can be adapted to other SQL dialects with
-- minimal changes.
--
-- הסקריפט הזה מלווה את פרויקט *Cross‑Platform Advertising Campaign Performance Analysis 2025*.
-- אני מגדיר כאן מבנה טבלה לשמירת נתוני פרסום, מדגים כיצד לטעון את מערך הנתונים לדוגמה,
-- ומציע מספר שאילתות לחישוב מדדי ביצוע מרכזיים (KPI) ולביצוע ניתוח מגמות חודש על חודש.
-- הסקריפט מניח סביבה של PostgreSQL אבל אני יכול להתאים אותו בקלות לדיאלקטים אחרים של SQL בשינויים מינימליים.

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
--
-- 1. יצירת טבלה לנתוני פרסום יומיים
--
-- בכל שורה אני מציג נתונים מצטברים עבור פלטפורמה אחת ביום נתון.
-- עמודות:
--  - date:        היום בלוח השנה (DATE)
--  - platform:    ערוץ הפרסום (לדוגמה, 'Facebook' או 'Google')
--  - impressions: מספר הפעמים שהמודעות הוצגו (INTEGER)
--  - clicks:      מספר ההקלקות על המודעות (INTEGER)
--  - cost:        סך ההוצאה ביום במטבע של הפלטפורמה (NUMERIC)
--  - conversions: מספר ההמרות או הפעולות (INTEGER)
--  - revenue:     הכנסה שמיוחסת להמרות אלה (NUMERIC)

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
--
-- 2. טעינת נתונים
--
-- אם יש לי הרשאות superuser, אני יכול לטעון את קובץ ה‑CSV שייצאתי באמצעות פקודת COPY.
-- אני מעדכן את נתיב הקובץ כך שיצביע למיקום של `ads_data.csv` במערכת שלי.
--
-- COPY ads_data
--   FROM '/absolute/path/to/ads_data.csv'
--   WITH (FORMAT csv, HEADER true);
--
-- לחילופין, אני משתמש בכלי צד לקוח כגון \copy של psql או מייבא את הנתונים דרך הממשק המועדף עלי של PostgreSQL.


/*
 * 3. Calculate aggregated KPIs per platform and overall
 *
 * This query returns the total impressions, clicks, cost, revenue and the key
 * metrics CTR, CPC, CPM and ROMI for each platform.  The final row
 * (using GROUPING SETS) aggregates across all platforms to provide overall
 * performance.
 */
--
-- 3. חישוב KPI מצטברים לכל פלטפורמה ובסך הכול
--
-- בשאילתה הזו אני מחזיר את סך ההופעות, ההקלקות, ההוצאות וההכנסות ואת המדדים העיקריים CTR, CPC, CPM ו‑ROMI עבור כל פלטפורמה.
-- השורה האחרונה (שמשתמשת ב‑GROUPING SETS) מאגדת את כל הפלטפורמות כדי לספק תמונת ביצועים כללית.

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
--
-- 4. חישוב KPI לפי חודש ופלטפורמה
--
-- בשאילתה הזו אני מקבץ את הנתונים לפי חודש קלנדרי ופלטפורמה ומחשב את אותם מדדים כמו לעיל.
-- זה שימושי לניתוח דפוסים עונתיים ולהשוואת ביצועים בין ערוצים.

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
--
-- 5. ניתוח מגמת חודש על חודש (MoM)
--
-- ביטוי הטבלה המשותפת (CTE) `monthly` מאגד את המדדים עבור כל הפלטפורמות בכל חודש.
-- השאילתה החיצונית משווה כל חודש לחודש הקודם באמצעות פונקציית החלון LAG כדי לחשב את אחוז השינוי בהופעות ובכל KPI.
-- זה עוזר לי לזהות מגמות של שיפור או ירידה בביצועים לאורך זמן.

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
--
-- 6. זיהוי החודשים בעלי הביצועים הטובים ביותר לפי ROMI עם הוצאה מינימלית
--
-- בשאילתה הזו אני מזהה חודשים שבהם ההוצאה הכוללת (העלות) עולה על סף מסוים ומסדר את התוצאות לפי ROMI בסדר יורד.
-- ניתן להתאים את הסף בהתאם להגדרה שלך להשקעה משמעותית בפרסום.

-- Set threshold for minimum monthly spend
-- הגדר סף להוצאה חודשית מינימלית
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

/*
 * 7. Determine which platform outperformed the other each month
 *
 * This query ranks platforms within each month by ROMI and returns the
 * platform with the highest return on marketing investment for each month.
 * It provides a simple way to see whether Facebook or Google delivered
 * the better return in any given period.
 */
--
-- 7. קביעת איזו פלטפורמה עלתה על השנייה בכל חודש
--
-- השאילתה הזו מדרגת את הפלטפורמות בכל חודש לפי ROMI ומחזירה את
-- הפלטפורמה עם החזר ההשקעה הגבוה ביותר בכל חודש.  כך ניתן לראות האם
-- Facebook או Google סיפקו את ההחזר הטוב ביותר בכל תקופה.

WITH monthly_platform AS (
    SELECT
        date_trunc('month', date)::DATE AS month,
        platform,
        ((SUM(revenue) - SUM(cost)) / NULLIF(SUM(cost),0)) AS romi
    FROM ads_data
    GROUP BY month, platform
), ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY month ORDER BY romi DESC) AS rn
    FROM monthly_platform
)
SELECT month,
       platform AS top_platform,
       romi AS top_platform_romi
FROM ranked
WHERE rn = 1
ORDER BY month;

/*
 * 8. Analyze performance by day of week and platform
 *
 * This query calculates aggregated metrics (impressions, clicks, cost, revenue)
 * and KPIs (CTR, CPC, CPM, ROMI) grouped by day of week and platform.  It
 * allows me to compare how each advertising channel performs on different
 * days of the week and identify high‑performing days for each platform.
 */
--
-- 8. ניתוח ביצועים לפי יום בשבוע ופלטפורמה
--
-- בשאילתה הזו אני מחשב את המדדים המצטברים (הופעות, הקלקות, עלות, הכנסה)
-- וה‑KPI (CTR, CPC, CPM, ROMI) בקיבוץ לפי יום בשבוע ופלטפורמה.  כך אני
-- יכול להשוות איך כל ערוץ פרסום מתפקד בימים שונים בשבוע ולזהות ימים
-- מוצלחים במיוחד לכל פלטפורמה.

SELECT
    EXTRACT(DOW FROM date) AS day_of_week,
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
GROUP BY day_of_week, platform
ORDER BY day_of_week, platform;
