USE PalestineStory;
GO

CREATE OR ALTER VIEW dbo.vw_ch6_gaza_monthly AS
SELECT d.year_month,
       SUM(c.killed_daily)  AS killed,
       SUM(c.injured_daily) AS injured,
       COUNT(*)             AS days_in_month,
       SUM(CASE WHEN c.is_reported = 1 THEN 1 ELSE 0 END) AS days_reported,
       AVG(CASE WHEN c.is_reported = 1 THEN CAST(c.killed_daily AS FLOAT) END) AS avg_daily_killed_reported_days
FROM fact.CasualtiesDaily c
JOIN dim.Date d ON d.date_key = c.date_key
WHERE c.geo_pcode = 'PS02'
GROUP BY d.year_month;
GO

CREATE OR ALTER VIEW dbo.vw_ch6_gaza_daily_ma7 AS
SELECT c.date_key, d.[date], c.killed_daily, c.injured_daily,
       c.is_reported, c.is_backlog_spike,
       AVG(CAST(c.killed_daily  AS FLOAT)) OVER (ORDER BY c.date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS killed_ma7,
       AVG(CAST(c.injured_daily AS FLOAT)) OVER (ORDER BY c.date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS injured_ma7
FROM fact.CasualtiesDaily c
JOIN dim.Date d ON d.date_key = c.date_key
WHERE c.geo_pcode = 'PS02';
GO

CREATE OR ALTER VIEW dbo.vw_ch6_gaza_latest AS
SELECT TOP (1)
       c.date_key, d.[date],
       c.killed_cum, c.injured_cum,
       c.children_killed_cum, c.women_killed_cum,
       CAST(c.children_killed_cum AS FLOAT) / NULLIF(c.killed_cum, 0) AS children_share,
       CAST(c.women_killed_cum    AS FLOAT) / NULLIF(c.killed_cum, 0) AS women_share
FROM fact.CasualtiesDaily c
JOIN dim.Date d ON d.date_key = c.date_key
WHERE c.geo_pcode = 'PS02'
ORDER BY c.date_key DESC;
GO

CREATE OR ALTER VIEW dbo.vw_ch6_gaza_top10_days AS
SELECT TOP (10)
       ROW_NUMBER() OVER (ORDER BY c.killed_daily DESC) AS rank_no,
       d.[date], c.killed_daily, c.injured_daily,
       c.is_backlog_spike, c.report_period_hours, c.report_source
FROM fact.CasualtiesDaily c
JOIN dim.Date d ON d.date_key = c.date_key
WHERE c.geo_pcode = 'PS02'
ORDER BY c.killed_daily DESC;
GO

CREATE OR ALTER VIEW dbo.vw_ch6_westbank_monthly AS
WITH w AS (
    SELECT d.year_month, c.killed_daily, c.injured_daily,
           c.settler_attacks_cum - COALESCE(LAG(c.settler_attacks_cum) OVER (ORDER BY c.date_key), 0) AS settler_attacks_daily
    FROM fact.CasualtiesDaily c
    JOIN dim.Date d ON d.date_key = c.date_key
    WHERE c.geo_pcode = 'PS01'
)
SELECT year_month,
       SUM(killed_daily)          AS killed,
       SUM(injured_daily)         AS injured,
       SUM(settler_attacks_daily) AS settler_attacks
FROM w
GROUP BY year_month;
GO

IF OBJECT_ID('fact.Population', 'U') IS NOT NULL
    EXEC('CREATE OR ALTER VIEW dbo.vw_ch6_gaza_killed_per_1000 AS
          SELECT l.date_key, l.killed_cum, p.population AS population_2023_projection,
                 CAST(l.killed_cum AS FLOAT) * 1000.0 / p.population AS killed_per_1000
          FROM (SELECT TOP (1) date_key, killed_cum FROM fact.CasualtiesDaily
                WHERE geo_pcode = ''PS02'' ORDER BY date_key DESC) l
          CROSS JOIN (SELECT population FROM fact.Population
                      WHERE geo_pcode = ''PS02'' AND [year] = 2023) p');
ELSE
    PRINT 'fact.Population is not loaded yet. Re-run this file after Shahd''s tables are loaded.';
GO
