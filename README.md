# Cross‑Platform Advertising Campaign Performance Analysis (2025)

![Cross‑platform marketing illustration](illustration.png)

## Project overview

This repository contains a self‑contained example of how to evaluate the
performance of cross‑platform digital advertising campaigns using SQL.  It
focuses on **Facebook Ads** and **Google Ads** — two of the most widely used
channels — and demonstrates how to calculate key performance indicators (KPIs),
analyse trends and identify optimisation opportunities in 2025.

The project includes a synthetic dataset that mimics daily campaign data from
**1 January 2024** through **31 August 2025** and a set of SQL queries that
aggregate and analyse this data.  You can use these scripts as a template for
your own marketing datasets or extend them with additional sources and
visualisation tools.

## Key metrics

When assessing digital campaigns, marketers typically monitor the following
metrics:

- **Cost per Click (CPC)** – the amount an advertiser pays for every click on an
  ad.  As explained in Pathlabs’ ad metrics guide, CPC measures the cost per
  click and serves both as a pricing model and a metric for campaign
  assessment【948272032911912†L162-L168】.  A low CPC indicates that you’re
  paying very little for click traffic, whereas a high CPC means each click is
  relatively expensive【948272032911912†L218-L224】.

- **Cost per Mille (CPM)** – the average cost per thousand ad impressions.  It
  measures how much an advertiser pays for every thousand times an ad is
  served【948272032911912†L229-L247】.  CPM is widely used at the top of the
  funnel when campaigns aim to increase brand awareness【948272032911912†L266-L269】.

- **Click‑Through Rate (CTR)** – the percentage of users who click an ad after
  seeing it.  CTR compares the number of clicks to the number of
  impressions【948272032911912†L382-L392】 and provides a cost‑independent view
  of engagement.  High CTR indicates strong creative or targeting, while a low
  CTR suggests the ad isn’t resonating with its audience.

- **Return on Marketing Investment (ROMI)** – the ratio of net profit to
  marketing spend.  ROMI measures the effectiveness and profitability of
  campaigns by comparing the revenue they generate to the cost of running
  them【494841379040022†L36-L45】.  It is calculated as:

  \[
  \text{ROMI} = \frac{\text{Revenue} - \text{Marketing Cost}}{\text{Marketing Cost}}
  \]

  A positive ROMI (greater than 0) indicates the campaign generated more
  revenue than it cost, while a negative ROMI signals that the campaign did not
  pay for itself.

These metrics provide complementary perspectives: CPC and CPM reflect the
efficiency of your spend; CTR captures engagement; and ROMI evaluates overall
profitability.

## Dataset

The file [`ads_data.csv`](./ads_data.csv) contains synthetic daily data for
Facebook and Google from 1 January 2024 through 31 August 2025.  Each row
represents the aggregated results for a single platform on a given day and
includes the following columns:

| Column       | Description                                                 |
|-------------|-------------------------------------------------------------|
| `date`      | Calendar day (YYYY‑MM‑DD)                                   |
| `platform`  | Advertising channel (`Facebook` or `Google`)                |
| `impressions` | Number of times ads were served                            |
| `clicks`    | Number of clicks on ads                                    |
| `cost`      | Total spend for that day (in arbitrary currency)            |
| `conversions` | Number of user actions attributed to the ads              |
| `revenue`   | Revenue generated from those conversions                    |

The dataset reflects a plausible scenario where advertising spend and
impressions gradually increase from 2024 into 2025.  Facebook generally
achieves higher click‑through rates and lower CPMs, while Google delivers more
expensive but potentially higher‑quality conversions.  Because the data is
artificial, it is safe to publish as part of a portfolio; however, you can
replace it with your own campaign data to perform a real‑world analysis.

## SQL analysis

All SQL queries reside in [`queries.sql`](./queries.sql).  The script
creates a table called `ads_data`, demonstrates how to import the CSV file
using `COPY` and provides several example queries:

1. **Platform‑level KPIs** – calculates total impressions, clicks, cost,
   revenue and derived metrics (CTR, CPC, CPM and ROMI) for each platform and
   overall.  Use this query to see which channel delivers better performance.
2. **Monthly aggregation** – groups data by calendar month and platform,
   computing the same metrics as above.  This helps you understand seasonal
   variations and compare channels over time.
3. **Month‑over‑month trend analysis** – summarises metrics across all
   platforms for each month and uses window functions to compute percentage
   changes from the previous month.  This is valuable for spotting emerging
   trends in impressions, CTR, CPC, CPM and ROMI.
4. **Top performing months** – filters for months with spend above a defined
   threshold and orders them by ROMI.  This highlights periods when your
   advertising investment delivered the highest returns.

To run these queries:

1. Install PostgreSQL 13 or later and create a new database (e.g., `marketing`).
2. Copy `ads_data.csv` into a directory accessible by your PostgreSQL server.
3. In a SQL client (such as `psql`), execute the table creation statement in
   `queries.sql` and use the `COPY` command to load the CSV into the
   `ads_data` table.
4. Execute the analysis queries one by one and review the results.

## Extending this project

Although this example focuses on SQL, you can enrich the analysis by
integrating Python or a BI tool such as Power BI or Tableau.  For instance,
after loading the data into PostgreSQL, you could connect to the database from
Python using SQLAlchemy and visualise monthly trends with matplotlib.  You
could also add additional columns (e.g., device type, region, or creative) to
perform more granular analyses.

If you use this repository in your portfolio, feel free to modify the
narrative and dataset to reflect your own campaign objectives.  Documenting
assumptions, clearly defining metrics and providing context — as done here —
helps hiring managers understand your analytical thinking and communication
skills.

## Sources

The definitions and interpretations of the key metrics used in this project
draw on authoritative digital marketing resources:

* **CPC and CPM definitions** – Pathlabs’ guide to ad metrics explains that
  cost per click (CPC) measures how much an advertiser pays for each click【948272032911912†L162-L168】,
  while cost per mille (CPM) captures the average cost per thousand impressions【948272032911912†L229-L247】.
* **CTR definition** – The same guide describes click‑through rate (CTR) as the
  percentage of users who click an ad after seeing it【948272032911912†L382-L392】.
* **ROMI definition and formula** – BidsCube’s adtech glossary notes that
  return on marketing investment (ROMI) measures the effectiveness and
  profitability of marketing campaigns and is calculated as the difference
  between revenue and marketing cost divided by the marketing cost【494841379040022†L36-L45】.

By grounding the analysis in commonly accepted definitions, you ensure that
your calculations align with industry practice and that your findings are
interpretable by colleagues and stakeholders.

## עברית

### סקירת הפרויקט

מאגר זה כולל דוגמה עצמאית לניתוח ביצועים של קמפיינים פרסומיים חוצי פלטפורמות באמצעות SQL. הפרויקט מתמקד בפייסבוק אדס ובגוגל אדס – שני ערוצי פרסום נפוצים – ומדגים כיצד לחשב מדדי ביצוע מרכזיים (KPIs), לנתח מגמות ולהצביע על הזדמנויות לשיפור בשנת 2025.

המאגר מכיל סט נתונים סינתטי המדמה נתוני קמפיין יומיים מ־1 בינואר 2024 ועד 31 אוגוסט 2025, וכן קובץ SQL עם שאילתות המאחדות ומנתחות את הנתונים. ניתן להשתמש בקוד כתבנית לפרויקטים משלכם או להרחיבו עם מקורות נוספים וכלי ויזואליזציה.

### מדדים מרכזיים

- **עלות לכל לחיצה (CPC)** – מדד למחיר שמשלם המפרסם עבור כל לחיצה על מודעה【948272032911912†L162-L168】.
- **עלות לאלף חשיפות (CPM)** – המחיר הממוצע שהמפרסם משלם עבור אלף חשיפות למודעה【948272032911912†L229-L247】.
- **שיעור קליקים (CTR)** – היחס בין מספר המשתמשים שהקליקו על מודעה לבין מספר החשיפות שלה【948272032911912†L382-L392】.
- **החזר השקעה שיווקית (ROMI)** – יחס בין הרווח הנקי מהקמפיין לבין עלות השיווק שלו.  מחושב כך:

  \[
  ROMI = \frac{\text{Revenue} - \text{Marketing Cost}}{\text{Marketing Cost}}
  \]

  מדד זה מבטא את יעילות ההוצאה השיווקית【494841379040022†L36-L45】.

### סט הנתונים

קובץ `ads_data.csv` מכיל נתונים יומיים לשתי הפלטפורמות במהלך התקופה, עם עמודות לתאריך, פלטפורמה, חשיפות, לחיצות, עלות, המרות והכנסה. הנתונים נבנו בצורה מלאכותית כך שישקפו עלייה הדרגתית בהוצאות ובחשיפות בין השנים 2024 ו־2025. אפשר להתאים את המבנה לנתונים אמיתיים לפי הצורך.

### ניתוח SQL

הקובץ `queries.sql` כולל:

1. יצירת טבלה לנתונים וטעינת קובץ ה־CSV באמצעות פקודת `COPY`.
2. שאילתה לחישוב סה״כ חשיפות, לחיצות, עלות, הכנסה ומדדים CTR, CPC, CPM ו‑ROMI לכל פלטפורמה ובסך הכול.
3. שאילתה לאגרגציה חודשית – סיכום הנתונים לפי חודש ופלטפורמה.
4. שאילתה לחישוב שינוי חודשי באחוזים במגוון המדדים.
5. זיהוי החודשים המניבים ביותר (ROMI גבוה) מעל סף הוצאה מסוים.

### הרחבת הפרויקט

אפשר לשלב את הנתונים עם Python או כלי BI כמו Power BI/Tableau לבניית ויזואליזציות או לבצע ניתוחים נוספים לפי מכשירים, אזורים וקריאייטיבים.  מאגר זה מתאים כתרגיל לעבודה עם נתוני פרסום ולבניית תיק עבודות של אנליסט.

### מקורות

הגדרות המדדים מבוססות על מקורות אמינים:

* ההסבר ל‑CPC ול‑CPM מתואר במאמר של Pathlabs【948272032911912†L162-L168】【948272032911912†L229-L247】.
* ההגדרה של CTR מתוארת באותו מאמר【948272032911912†L382-L392】.
* ההגדרה של ROMI והנוסחה לחישוב נלקחו ממילון המונחים של BidsCube【494841379040022†L36-L45】.