USE PalestineStory;
GO
DROP TABLE IF EXISTS dim.Geography;
CREATE TABLE dim.Geography (
    geo_pcode     NVARCHAR(10)  NOT NULL PRIMARY KEY,
    geo_level     NVARCHAR(20)  NOT NULL,
    geo_name      NVARCHAR(100) NOT NULL,
    region_pcode  NVARCHAR(10)  NULL,
    region_name   NVARCHAR(100) NULL,
    area_sqkm     DECIMAL(18,8) NULL,
    center_lat    DECIMAL(12,8) NULL,
    center_lon    DECIMAL(12,8) NULL
);

DROP TABLE IF EXISTS dim.Date;
CREATE TABLE dim.Date (
    date_key        INT          NOT NULL PRIMARY KEY,
    [date]          DATE         NOT NULL,
    [year]          INT          NOT NULL,
    [quarter]       INT          NOT NULL,
    [month]         INT          NOT NULL,
    month_name      NVARCHAR(20) NOT NULL,
    year_month      NVARCHAR(7)  NOT NULL,
    month_start     DATE         NOT NULL,
    week_start      DATE         NOT NULL,
    is_story_period BIT          NOT NULL,
    is_war_period   BIT          NOT NULL
);

DROP TABLE IF EXISTS dim.[Year];
CREATE TABLE dim.[Year] (
    [year]          INT NOT NULL PRIMARY KEY,
    is_story_period BIT NOT NULL,
    is_war_year     BIT NOT NULL
);
GO
-- load (re-runnable)
TRUNCATE TABLE dim.Geography;
BULK INSERT dim.Geography FROM 'C:\PalestineData\clean\dim_geography.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', TABLOCK);

TRUNCATE TABLE dim.Date;
BULK INSERT dim.Date FROM 'C:\PalestineData\clean\dim_date.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE dim.[Year];
BULK INSERT dim.[Year] FROM 'C:\PalestineData\clean\dim_year.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a', TABLOCK);
GO
SELECT (SELECT COUNT(*) FROM dim.Geography) AS geography_19,
       (SELECT COUNT(*) FROM dim.Date)      AS date_7305,
       (SELECT COUNT(*) FROM dim.[Year])    AS year_67;