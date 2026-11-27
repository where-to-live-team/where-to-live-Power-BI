USE PalestineStory;
GO

CREATE OR ALTER VIEW dbo.vw_ch3_gdp_2016_2025 AS
SELECT w.[year], y.is_war_year,
       MAX(CASE WHEN w.indicator_code = 'NY.GDP.MKTP.CD' THEN w.value END) AS gdp_current_usd,
       MAX(CASE WHEN w.indicator_code = 'NY.GDP.PCAP.CD' THEN w.value END) AS gdp_per_capita_usd
FROM fact.WorldBank w
JOIN dim.[Year] y ON y.[year] = w.[year]
WHERE w.indicator_code IN ('NY.GDP.MKTP.CD', 'NY.GDP.PCAP.CD')
  AND y.is_story_period = 1 AND w.[year] <= 2025
GROUP BY w.[year], y.is_war_year;
GO

CREATE OR ALTER VIEW dbo.vw_ch3_gdp_growth AS
SELECT w.[year], y.is_war_year, w.value AS gdp_growth_pct
FROM fact.WorldBank w
JOIN dim.[Year] y ON y.[year] = w.[year]
WHERE w.indicator_code = 'NY.GDP.MKTP.KD.ZG'
  AND y.is_story_period = 1 AND w.[year] <= 2025;
GO

CREATE OR ALTER VIEW dbo.vw_ch3_inflation AS
SELECT w.[year], y.is_war_year, w.value AS inflation_pct, w.needs_review_flag
FROM fact.WorldBank w
JOIN dim.[Year] y ON y.[year] = w.[year]
WHERE w.indicator_code = 'FP.CPI.TOTL.ZG'
  AND y.is_story_period = 1 AND w.[year] <= 2025;
GO

CREATE OR ALTER VIEW dbo.vw_ch3_unemployment_headline AS
SELECT u.[year], y.is_war_year, u.sex,
       u.value AS unemployment_rate_pct, u.obs_status, u.series_break_flag
FROM fact.UnemploymentILO u
JOIN dim.[Year] y ON y.[year] = u.[year]
WHERE u.indicator_code = 'UNE_DEAP_SEX_AGE_RT'
  AND u.age_class = 'AGE_YTHADULT_YGE15';
GO

CREATE OR ALTER VIEW dbo.vw_ch3_labour_force_participation AS
SELECT w.[year], y.is_war_year,
       MAX(CASE WHEN w.indicator_code = 'SL.TLF.CACT.ZS'    THEN w.value END) AS participation_total_pct,
       MAX(CASE WHEN w.indicator_code = 'SL.TLF.CACT.FE.ZS' THEN w.value END) AS participation_female_pct
FROM fact.WorldBank w
JOIN dim.[Year] y ON y.[year] = w.[year]
WHERE w.indicator_code IN ('SL.TLF.CACT.ZS', 'SL.TLF.CACT.FE.ZS')
  AND y.is_story_period = 1 AND w.[year] <= 2025
GROUP BY w.[year], y.is_war_year;
GO

CREATE OR ALTER VIEW dbo.vw_ch3_prewar_vs_latest AS
WITH picked AS (
    SELECT indicator_code, [year], value, needs_review_flag
    FROM fact.WorldBank
    WHERE indicator_code IN ('NY.GDP.PCAP.CD', 'NY.GDP.MKTP.KD.ZG', 'FP.CPI.TOTL.ZG', 'SL.UEM.TOTL.ZS', 'SL.TLF.CACT.ZS')
      AND value IS NOT NULL
),
pre AS (
    SELECT indicator_code, AVG(value) AS prewar_avg_2016_2022, COUNT(*) AS prewar_years
    FROM picked
    WHERE [year] BETWEEN 2016 AND 2022
    GROUP BY indicator_code
),
latest AS (
    SELECT indicator_code, [year] AS latest_year, value AS latest_value, needs_review_flag,
           ROW_NUMBER() OVER (PARTITION BY indicator_code ORDER BY [year] DESC) AS rn
    FROM picked
)
SELECT i.indicator_name, p.indicator_code,
       p.prewar_avg_2016_2022, p.prewar_years,
       l.latest_year, l.latest_value,
       l.latest_value - p.prewar_avg_2016_2022 AS change_abs,
       CASE WHEN l.latest_year >= 2023 THEN 1 ELSE 0 END AS latest_is_war_period,
       l.needs_review_flag
FROM pre p
JOIN latest l ON l.indicator_code = p.indicator_code AND l.rn = 1
JOIN dim.Indicator i ON i.indicator_code = p.indicator_code;
GO
