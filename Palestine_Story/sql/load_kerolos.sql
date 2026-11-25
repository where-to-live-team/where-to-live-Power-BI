USE PalestineStory;
GO
TRUNCATE TABLE dim.Indicator;
BULK INSERT dim.Indicator FROM 'C:\PalestineData\clean\dim_indicator.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE dim.DamageClass;
BULK INSERT dim.DamageClass FROM 'C:\PalestineData\clean\dim_damage_class.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE dim.DamageRound;
BULK INSERT dim.DamageRound FROM 'C:\PalestineData\clean\dim_damage_round.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE dim.DamageSite;
BULK INSERT dim.DamageSite FROM 'C:\PalestineData\clean\dim_damage_site.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE fact.WorldBank;
BULK INSERT fact.WorldBank FROM 'C:\PalestineData\clean\fact_worldbank.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE fact.UnemploymentILO;
BULK INSERT fact.UnemploymentILO FROM 'C:\PalestineData\clean\fact_unemployment_ilo.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE fact.BuildingsDamagedDaily;
BULK INSERT fact.BuildingsDamagedDaily FROM 'C:\PalestineData\clean\fact_buildings_damaged_daily.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE fact.CasualtiesDaily;
BULK INSERT fact.CasualtiesDaily FROM 'C:\PalestineData\clean\fact_casualties_daily.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE fact.DamageSiteRound;
BULK INSERT fact.DamageSiteRound FROM 'C:\PalestineData\clean\fact_damage_site_round.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);
GO