USE PalestineStory;
GO
WITH c AS (
  SELECT 'dim.Geography rows' AS check_name, CAST(COUNT(*) AS DECIMAL(38,2)) AS value, CAST(19 AS DECIMAL(38,2)) AS expected FROM dim.Geography
  UNION ALL SELECT 'dim.Date rows', COUNT(*), 7305 FROM dim.Date
  UNION ALL SELECT 'dim.Year rows', COUNT(*), 67 FROM dim.[Year]
  UNION ALL SELECT 'dim.Indicator rows', COUNT(*), 27 FROM dim.Indicator
  UNION ALL SELECT 'fact.WorldBank rows', COUNT(*), 736 FROM fact.WorldBank
  UNION ALL SELECT 'WB SP.POP.TOTL 2023', value, 5165775 FROM fact.WorldBank WHERE indicator_code='SP.POP.TOTL' AND [year]=2023
  UNION ALL SELECT 'WB GDP 2024 (billion)', ROUND(value/1000000000.0,2), 16.02 FROM fact.WorldBank WHERE indicator_code='NY.GDP.MKTP.CD' AND [year]=2024
  UNION ALL SELECT 'WB inflation 2024', ROUND(value,2), 53.67 FROM fact.WorldBank WHERE indicator_code='FP.CPI.TOTL.ZG' AND [year]=2024
  UNION ALL SELECT 'fact.UnemploymentILO rows', COUNT(*), 6310 FROM fact.UnemploymentILO
  UNION ALL SELECT 'ILO rows in 2023', COUNT(*), 0 FROM fact.UnemploymentILO WHERE [year]=2023
  UNION ALL SELECT 'ILO headline 2022', ROUND(value,2), 24.42 FROM fact.UnemploymentILO WHERE indicator_code='UNE_DEAP_SEX_AGE_RT' AND sex='Total' AND age_class='AGE_YTHADULT_YGE15' AND [year]=2022
  UNION ALL SELECT 'ILO headline 2024', ROUND(value,2), 31.44 FROM fact.UnemploymentILO WHERE indicator_code='UNE_DEAP_SEX_AGE_RT' AND sex='Total' AND age_class='AGE_YTHADULT_YGE15' AND [year]=2024
  UNION ALL SELECT 'fact.BuildingsDamagedDaily rows', COUNT(*), 5081 FROM fact.BuildingsDamagedDaily
  UNION ALL SELECT 'Buildings residential destroyed 2025-10-05', count_cum, 416000 FROM fact.BuildingsDamagedDaily WHERE date_key=20251005 AND category='residential' AND status='destroyed'
  UNION ALL SELECT 'fact.CasualtiesDaily rows', COUNT(*), 2274 FROM fact.CasualtiesDaily
  UNION ALL SELECT 'Gaza killed_cum 2026-11-16', killed_cum, 74702 FROM fact.CasualtiesDaily WHERE geo_pcode='PS02' AND date_key=20261116
  UNION ALL SELECT 'Gaza injured_cum 2026-11-16', injured_cum, 176105 FROM fact.CasualtiesDaily WHERE geo_pcode='PS02' AND date_key=20261116
  UNION ALL SELECT 'WB killed_cum 2026-11-16', killed_cum, 1129 FROM fact.CasualtiesDaily WHERE geo_pcode='PS01' AND date_key=20261116
  UNION ALL SELECT 'WB settler_attacks_cum 2026-11-16', settler_attacks_cum, 5212 FROM fact.CasualtiesDaily WHERE geo_pcode='PS01' AND date_key=20261116
  UNION ALL SELECT 'Gaza not-reported days', COUNT(*), 49 FROM fact.CasualtiesDaily WHERE geo_pcode='PS02' AND is_reported=0
  UNION ALL SELECT 'Gaza filled days', COUNT(*), 31 FROM fact.CasualtiesDaily WHERE geo_pcode='PS02' AND is_filled=1
  UNION ALL SELECT 'Gaza backlog-spike days', COUNT(*), 12 FROM fact.CasualtiesDaily WHERE geo_pcode='PS02' AND is_backlog_spike=1
  UNION ALL SELECT 'WB filled rows', COUNT(*), 871 FROM fact.CasualtiesDaily WHERE geo_pcode='PS01' AND is_filled=1
  UNION ALL SELECT 'dim.DamageSite rows', COUNT(*), 192851 FROM dim.DamageSite
  UNION ALL SELECT 'DamageSite distinct (lon,lat)', COUNT(*), 192851 FROM (SELECT DISTINCT lon, lat FROM dim.DamageSite) x
  UNION ALL SELECT 'fact.DamageSiteRound rows', COUNT(*), 1648583 FROM fact.DamageSiteRound
  UNION ALL SELECT 'DamageSiteRound round 1', COUNT(*), 15637 FROM fact.DamageSiteRound WHERE round_no=1
  UNION ALL SELECT 'DamageSiteRound round 13', COUNT(*), 192851 FROM fact.DamageSiteRound WHERE round_no=13
  UNION ALL SELECT 'Round 13 class 1', COUNT(*), 102067 FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=1
  UNION ALL SELECT 'Round 13 class 2', COUNT(*), 17421  FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=2
  UNION ALL SELECT 'Round 13 class 3', COUNT(*), 41895  FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=3
  UNION ALL SELECT 'Round 13 class 4', COUNT(*), 28649  FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=4
  UNION ALL SELECT 'Round 13 class 6', COUNT(*), 39     FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=6
  UNION ALL SELECT 'Round 13 class 11', COUNT(*), 2780  FROM fact.DamageSiteRound WHERE round_no=13 AND damage_class=11
)
SELECT check_name, value, expected,
       CASE WHEN value = expected THEN 'OK' ELSE '<<< DIFF' END AS status
FROM c
ORDER BY check_name;
GO