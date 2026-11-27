USE PalestineStory;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_class_share_r13_by_gov AS
SELECT s.geo_pcode,
       COALESCE(g.geo_name, 'Unknown') AS governorate,
       r.damage_class, cl.class_label, cl.severity_rank,
       COUNT(*) AS n_sites,
       CAST(COUNT(*) AS FLOAT) / SUM(COUNT(*)) OVER (PARTITION BY s.geo_pcode) AS share_of_governorate
FROM fact.DamageSiteRound r
JOIN dim.DamageSite  s  ON s.site_key = r.site_key
JOIN dim.DamageClass cl ON cl.damage_class = r.damage_class
LEFT JOIN dim.Geography g ON g.geo_pcode = s.geo_pcode
WHERE r.round_no = 13
GROUP BY s.geo_pcode, g.geo_name, r.damage_class, cl.class_label, cl.severity_rank;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_sites_by_round_class AS
SELECT r.round_no, rd.sensor_date_min, rd.sensor_date_max,
       r.damage_class, cl.class_label,
       COUNT(*)                                AS n_sites,
       rd.n_sites_assessed,
       CAST(COUNT(*) AS FLOAT) / rd.n_sites_assessed AS share_of_round
FROM fact.DamageSiteRound r
JOIN dim.DamageRound rd ON rd.round_no = r.round_no
JOIN dim.DamageClass cl ON cl.damage_class = r.damage_class
GROUP BY r.round_no, rd.sensor_date_min, rd.sensor_date_max, rd.n_sites_assessed,
         r.damage_class, cl.class_label;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_top10_neighborhoods_destroyed AS
WITH n AS (
    SELECT COALESCE(g.geo_name, 'Unknown') AS governorate, s.municipality, s.neighborhood,
           COUNT(*) AS n_sites,
           SUM(CASE WHEN s.final_class = 1 THEN 1 ELSE 0 END) AS n_destroyed
    FROM dim.DamageSite s
    LEFT JOIN dim.Geography g ON g.geo_pcode = s.geo_pcode
    WHERE s.neighborhood IS NOT NULL
    GROUP BY g.geo_name, s.municipality, s.neighborhood
)
SELECT TOP (10)
       ROW_NUMBER() OVER (ORDER BY n_destroyed DESC, neighborhood) AS rank_no,
       governorate, municipality, neighborhood, n_sites, n_destroyed,
       CAST(n_destroyed AS FLOAT) / n_sites AS destroyed_share
FROM n
ORDER BY n_destroyed DESC, neighborhood;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_sites_per_km2_by_gov AS
SELECT g.geo_pcode, g.geo_name AS governorate, g.area_sqkm,
       COUNT(*) AS sites_all_classes,
       SUM(CASE WHEN s.final_class = 1 THEN 1 ELSE 0 END)        AS sites_destroyed,
       SUM(CASE WHEN s.final_class IN (1, 2, 3) THEN 1 ELSE 0 END) AS sites_class_1_to_3,
       CAST(COUNT(*) AS FLOAT) / NULLIF(g.area_sqkm, 0) AS all_classes_per_km2,
       CAST(SUM(CASE WHEN s.final_class = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(g.area_sqkm, 0) AS destroyed_per_km2,
       CAST(SUM(CASE WHEN s.final_class IN (1, 2, 3) THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(g.area_sqkm, 0) AS class_1_to_3_per_km2
FROM dim.DamageSite s
JOIN dim.Geography g ON g.geo_pcode = s.geo_pcode
GROUP BY g.geo_pcode, g.geo_name, g.area_sqkm;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_first_detected_by_round_gov AS
SELECT s.first_round_no AS round_no, rd.sensor_date_min, rd.sensor_date_max,
       s.geo_pcode, COALESCE(g.geo_name, 'Unknown') AS governorate,
       COUNT(*) AS new_sites
FROM dim.DamageSite s
JOIN dim.DamageRound rd ON rd.round_no = s.first_round_no
LEFT JOIN dim.Geography g ON g.geo_pcode = s.geo_pcode
GROUP BY s.first_round_no, rd.sensor_date_min, rd.sensor_date_max, s.geo_pcode, g.geo_name;
GO

CREATE OR ALTER VIEW dbo.vw_ch2_buildings_daily AS
SELECT b.date_key, d.[date], b.category, b.status,
       b.count_cum, b.count_daily, b.is_decrease_flag,
       'Official claims (building counts), not UNOSAT damage sites' AS source_label
FROM fact.BuildingsDamagedDaily b
JOIN dim.Date d ON d.date_key = b.date_key;
GO
