USE PalestineStory;
GO
DROP TABLE IF EXISTS dim.Indicator;
CREATE TABLE dim.Indicator (
    indicator_code NVARCHAR(40)  NOT NULL PRIMARY KEY,
    indicator_name NVARCHAR(300) NOT NULL,
    theme          NVARCHAR(30)  NULL,
    source         NVARCHAR(10)  NOT NULL
);

DROP TABLE IF EXISTS fact.WorldBank;
CREATE TABLE fact.WorldBank (
    indicator_code     NVARCHAR(40)   NOT NULL,
    [year]             INT            NOT NULL,
    value              DECIMAL(24,6)  NULL,
    is_unreliable_flag BIT            NOT NULL,
    needs_review_flag  BIT            NOT NULL,
    PRIMARY KEY (indicator_code, [year])
);

DROP TABLE IF EXISTS fact.UnemploymentILO;
CREATE TABLE fact.UnemploymentILO (
    [year]            INT           NOT NULL,
    indicator_code    NVARCHAR(40)  NOT NULL,
    sex               NVARCHAR(10)  NOT NULL,
    age_class         NVARCHAR(60)  NULL,
    edu_class         NVARCHAR(60)  NULL,
    value             DECIMAL(18,4) NULL,
    obs_status        NVARCHAR(5)   NULL,
    series_break_flag BIT           NOT NULL
);
CREATE CLUSTERED INDEX ix_unemp ON fact.UnemploymentILO ([year], indicator_code);

DROP TABLE IF EXISTS fact.BuildingsDamagedDaily;
CREATE TABLE fact.BuildingsDamagedDaily (
    date_key         INT          NOT NULL,
    category         NVARCHAR(20) NOT NULL,
    status           NVARCHAR(20) NOT NULL,
    count_cum        INT          NULL,
    count_daily      INT          NULL,
    is_decrease_flag BIT          NOT NULL,
    PRIMARY KEY (date_key, category, status)
);

DROP TABLE IF EXISTS fact.CasualtiesDaily;
CREATE TABLE fact.CasualtiesDaily (
    date_key                 INT          NOT NULL,
    geo_pcode                NVARCHAR(10) NOT NULL,
    killed_cum               INT NULL, killed_daily   INT NULL,
    injured_cum              INT NULL, injured_daily  INT NULL,
    children_killed_cum      INT NULL, women_killed_cum INT NULL,
    medical_killed_cum       INT NULL, press_killed_cum INT NULL,
    civil_defense_killed_cum INT NULL, massacres_cum    INT NULL,
    famine_deaths_cum        INT NULL, child_famine_deaths_cum INT NULL,
    aid_seekers_killed_cum   INT NULL, aid_seekers_injured_cum INT NULL,
    settler_attacks_cum      INT NULL, displaced_persons_cum   INT NULL,
    report_source            NVARCHAR(30) NULL,
    report_period_hours      INT NULL,
    is_reported              BIT NOT NULL,
    is_filled                BIT NOT NULL,
    is_multi_day_report      BIT NULL,
    is_backlog_spike         BIT NULL,
    PRIMARY KEY (date_key, geo_pcode)
);

DROP TABLE IF EXISTS dim.DamageClass;
CREATE TABLE dim.DamageClass (
    damage_class  SMALLINT      NOT NULL PRIMARY KEY,
    class_label   NVARCHAR(100) NOT NULL,
    severity_rank TINYINT       NOT NULL
);

DROP TABLE IF EXISTS dim.DamageRound;
CREATE TABLE dim.DamageRound (
    round_no         TINYINT NOT NULL PRIMARY KEY,
    sensor_date_min  DATE    NULL,
    sensor_date_max  DATE    NULL,
    n_sites_assessed INT     NOT NULL
);

DROP TABLE IF EXISTS dim.DamageSite;
CREATE TABLE dim.DamageSite (
    site_key                   INT           NOT NULL PRIMARY KEY,
    source_site_group_id       NVARCHAR(50)  NULL,
    lon                        FLOAT         NOT NULL,
    lat                        FLOAT         NOT NULL,
    geo_pcode                  NVARCHAR(10)  NULL,
    municipality               NVARCHAR(200) NULL,
    neighborhood               NVARCHAR(200) NULL,
    site_note                  NVARCHAR(MAX) NULL,
    event_code_raw             NVARCHAR(50)  NULL,
    event_code_std             NVARCHAR(50)  NULL,
    event_code_suspect_flag    BIT           NOT NULL,
    first_round_no             TINYINT       NOT NULL,
    final_class                SMALLINT      NULL,
    has_class_improvement_flag BIT           NOT NULL
);

DROP TABLE IF EXISTS fact.DamageSiteRound;
CREATE TABLE fact.DamageSiteRound (
    site_key      INT      NOT NULL,
    round_no      TINYINT  NOT NULL,
    sensor_date   DATE     NULL,
    sensor_id     SMALLINT NULL,
    confidence_id SMALLINT NULL,
    damage_class  SMALLINT NOT NULL,
    damage_status SMALLINT NULL,
    PRIMARY KEY (site_key, round_no)
);

DROP TABLE IF EXISTS ml.GovernorateCluster;
CREATE TABLE ml.GovernorateCluster (
    geo_pcode        NVARCHAR(10)  NOT NULL PRIMARY KEY,
    cluster_id       INT           NOT NULL,
    cluster_label    NVARCHAR(100) NULL,
    model_name       NVARCHAR(50)  NULL,
    features_used    NVARCHAR(500) NULL,
    silhouette_score DECIMAL(9,6)  NULL
);
GO