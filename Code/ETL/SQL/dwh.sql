-- ==========================================================================
-- Script tạo lại toàn bộ Data Warehouse: LinkedInDW
-- Bao gồm tạo Database, DROP các bảng cũ, CREATE các bảng mới
-- với cấu trúc DimDate chi tiết hơn.
-- ==========================================================================

-- Bước 0: Tạo Database nếu chưa tồn tại
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'LinkedInDW')
BEGIN
    CREATE DATABASE LinkedInDW;
    PRINT 'Database LinkedInDW created.';
END
ELSE
BEGIN
    PRINT 'Database LinkedInDW already exists.';
END
GO

USE LinkedInDW;
GO

PRINT 'Starting to DROP and CREATE tables in LinkedInDW...';
GO

-- ==========================================================================
-- Bước 1: DROP các bảng theo đúng thứ tự (để tránh lỗi khóa ngoại)
-- ==========================================================================

-- Bridge Tables (phụ thuộc vào Dimension)
PRINT 'Dropping Bridge Tables...';
IF OBJECT_ID('dbo.BridgeCompanySpeciality', 'U') IS NOT NULL DROP TABLE dbo.BridgeCompanySpeciality;
IF OBJECT_ID('dbo.BridgeCompanyIndustry', 'U') IS NOT NULL DROP TABLE dbo.BridgeCompanyIndustry;
IF OBJECT_ID('dbo.BridgeJobBenefit', 'U') IS NOT NULL DROP TABLE dbo.BridgeJobBenefit;
IF OBJECT_ID('dbo.BridgeJobIndustry', 'U') IS NOT NULL DROP TABLE dbo.BridgeJobIndustry;
IF OBJECT_ID('dbo.BridgeJobSkill', 'U') IS NOT NULL DROP TABLE dbo.BridgeJobSkill;
GO

-- Fact Tables (phụ thuộc vào Dimension)
PRINT 'Dropping Fact Tables...';
IF OBJECT_ID('dbo.FactJobPosting', 'U') IS NOT NULL DROP TABLE dbo.FactJobPosting;
IF OBJECT_ID('dbo.FactCompanySnapshot', 'U') IS NOT NULL DROP TABLE dbo.FactCompanySnapshot;
GO

-- Dimension Tables (bảng DimJob phụ thuộc DimCompany và DimExperienceLevel)
PRINT 'Dropping Dimension Tables...';
IF OBJECT_ID('dbo.DimJob', 'U') IS NOT NULL DROP TABLE dbo.DimJob;
-- Các dimension độc lập hoặc ít phụ thuộc hơn
IF OBJECT_ID('dbo.DimCompensationDetails', 'U') IS NOT NULL DROP TABLE dbo.DimCompensationDetails;
IF OBJECT_ID('dbo.DimSpeciality', 'U') IS NOT NULL DROP TABLE dbo.DimSpeciality;
IF OBJECT_ID('dbo.DimBenefitType', 'U') IS NOT NULL DROP TABLE dbo.DimBenefitType;
IF OBJECT_ID('dbo.DimExperienceLevel', 'U') IS NOT NULL DROP TABLE dbo.DimExperienceLevel;
IF OBJECT_ID('dbo.DimIndustry', 'U') IS NOT NULL DROP TABLE dbo.DimIndustry;
IF OBJECT_ID('dbo.DimSkill', 'U') IS NOT NULL DROP TABLE dbo.DimSkill;
IF OBJECT_ID('dbo.DimLocation', 'U') IS NOT NULL DROP TABLE dbo.DimLocation;
IF OBJECT_ID('dbo.DimCompany', 'U') IS NOT NULL DROP TABLE dbo.DimCompany;
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL DROP TABLE dbo.DimDate;
GO

PRINT 'All existing tables dropped (if they existed).';
GO

-- ==========================================================================
-- Bước 2: CREATE các bảng Dimension
-- ==========================================================================
PRINT 'Creating Dimension Tables...';
GO

-- DimDate: Sử dụng cấu trúc chi tiết hơn để phù hợp với Stg_DimDate (Kimball-style)
CREATE TABLE dbo.DimDate (
    DateSK INT NOT NULL PRIMARY KEY,
    DateValue DATE NOT NULL UNIQUE,
    DayOfWeek TINYINT NOT NULL,
    DayNumInMonth TINYINT NOT NULL,
    DayNumOverall SMALLINT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    DayAbbrev CHAR(3) NOT NULL,
    IsWeekend BIT NOT NULL,
    WeekNumInYear TINYINT NOT NULL,
    WeekNumOverall SMALLINT NULL,         -- Có thể NULL nếu không dùng
    WeekBeginDate DATE NULL,             -- Có thể NULL nếu không dùng
    WeekBeginDateKey INT NULL,           -- Có thể NULL nếu không dùng
    Month TINYINT NOT NULL,
    MonthNumOverall SMALLINT NULL,        -- Có thể NULL nếu không dùng
    MonthName VARCHAR(10) NOT NULL,
    MonthAbbrev CHAR(3) NOT NULL,
    Quarter TINYINT NOT NULL,
    Year SMALLINT NOT NULL,
    YearMonth INT NOT NULL,                  -- YYYYMM
    FiscalMonth TINYINT NULL,             -- Có thể NULL nếu không dùng
    FiscalQuarter TINYINT NULL,           -- Có thể NULL nếu không dùng
    FiscalYear SMALLINT NULL,             -- Có thể NULL nếu không dùng
    LastDayInMonthFlag BIT NULL,        -- Có thể NULL nếu không dùng
    SameDayYearAgoDate DATE NULL         -- Có thể NULL nếu không dùng
);
PRINT 'Table DimDate created.';
GO

CREATE TABLE dbo.DimCompany (
    CompanySK INT IDENTITY(1,1) PRIMARY KEY,
    CompanyID INT NOT NULL,
    Name NVARCHAR(255),
    Description NVARCHAR(MAX),
    CompanySizeRaw FLOAT,
    State NVARCHAR(100),
    Country NVARCHAR(100),
    City NVARCHAR(500),
    ZipCode NVARCHAR(255),
    Address NVARCHAR(500),
    URL NVARCHAR(500),
    EmployeeCount INT,
    FollowerCount INT,
    SourceTimeRecorded DATETIME2,
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimCompany created.';
GO
CREATE INDEX IDX_DimCompany_NK_Current ON dbo.DimCompany (CompanyID, IsCurrent);
CREATE INDEX IDX_DimCompany_NK_History ON dbo.DimCompany (CompanyID, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimLocation (
    LocationSK INT IDENTITY(1,1) PRIMARY KEY,
    LocationString NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(100),
    Country NVARCHAR(100),
    ZipCode NVARCHAR(255),
    FIPS NVARCHAR(20),
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimLocation created.';
GO
ALTER TABLE dbo.DimLocation ADD LocationStringNormalized AS (ISNULL(LocationString, ''));
ALTER TABLE dbo.DimLocation ADD ZipCodeNormalized AS (ISNULL(ZipCode, ''));
ALTER TABLE dbo.DimLocation ADD FIPSNormalized AS (ISNULL(FIPS, ''));
GO
CREATE UNIQUE INDEX IDX_DimLocation_UniqueVersion ON dbo.DimLocation
    (LocationStringNormalized, ZipCodeNormalized, FIPSNormalized, ValidFrom);
CREATE INDEX IDX_DimLocation_Current ON dbo.DimLocation (LocationSK, IsCurrent);
GO

CREATE TABLE dbo.DimSkill (
    SkillSK INT IDENTITY(1,1) PRIMARY KEY,
    SkillAbr NVARCHAR(100) NOT NULL,
    SkillName NVARCHAR(255),
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimSkill created.';
GO
CREATE UNIQUE INDEX IDX_DimSkill_NK_Current ON dbo.DimSkill (SkillAbr, IsCurrent);
CREATE INDEX IDX_DimSkill_NK_History ON dbo.DimSkill (SkillAbr, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimIndustry (
    IndustrySK INT IDENTITY(1,1) PRIMARY KEY,
    IndustryID INT NOT NULL,
    IndustryName NVARCHAR(255),
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimIndustry created.';
GO
CREATE UNIQUE INDEX IDX_DimIndustry_NK_Current ON dbo.DimIndustry (IndustryID, IsCurrent);
CREATE INDEX IDX_DimIndustry_NK_History ON dbo.DimIndustry (IndustryID, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimExperienceLevel (
    ExperienceLevelSK INT IDENTITY(1,1) PRIMARY KEY,
    FormattedExperienceLevel NVARCHAR(100) NOT NULL,
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimExperienceLevel created.';
GO
CREATE UNIQUE INDEX IDX_DimExperienceLevel_NK_Current ON dbo.DimExperienceLevel (FormattedExperienceLevel, IsCurrent);
CREATE INDEX IDX_DimExperienceLevel_NK_History ON dbo.DimExperienceLevel (FormattedExperienceLevel, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimBenefitType (
    BenefitTypeSK INT IDENTITY(1,1) PRIMARY KEY,
    BenefitName NVARCHAR(255) NOT NULL,
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimBenefitType created.';
GO
CREATE UNIQUE INDEX IDX_DimBenefitType_NK_Current ON dbo.DimBenefitType (BenefitName, IsCurrent);
CREATE INDEX IDX_DimBenefitType_NK_History ON dbo.DimBenefitType (BenefitName, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimSpeciality (
    SpecialitySK INT IDENTITY(1,1) PRIMARY KEY,
    SpecialityName NVARCHAR(MAX) NOT NULL,
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimSpeciality created.';
GO
-- Need to add a hashed version of SpecialityName to index since NVARCHAR(MAX) cannot be indexed directly
ALTER TABLE dbo.DimSpeciality ADD SpecialityNameHash AS CAST(HASHBYTES('SHA2_256', CAST(SpecialityName AS NVARCHAR(4000))) AS VARBINARY(32));
GO
CREATE UNIQUE INDEX IDX_DimSpeciality_NK_Current ON dbo.DimSpeciality (SpecialityNameHash, IsCurrent);
CREATE INDEX IDX_DimSpeciality_NK_History ON dbo.DimSpeciality (SpecialityNameHash, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimCompensationDetails (
    CompensationDetailsSK INT IDENTITY(1,1) PRIMARY KEY,
    PayPeriod NVARCHAR(50),
    Currency NVARCHAR(10),
    CompensationType NVARCHAR(50),
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL,
    IsCurrent BIT NOT NULL
);
PRINT 'Table DimCompensationDetails created.';
GO
ALTER TABLE dbo.DimCompensationDetails ADD PayPeriodNormalized AS (ISNULL(PayPeriod, 'N/A'));
ALTER TABLE dbo.DimCompensationDetails ADD CurrencyNormalized AS (ISNULL(Currency, 'N/A'));
ALTER TABLE dbo.DimCompensationDetails ADD CompensationTypeNormalized AS (ISNULL(CompensationType, 'N/A'));
GO
CREATE UNIQUE INDEX IDX_DimCompensationDetails_Unique_Current ON dbo.DimCompensationDetails
    (PayPeriodNormalized, CurrencyNormalized, CompensationTypeNormalized, IsCurrent);
CREATE INDEX IDX_DimCompensationDetails_History ON dbo.DimCompensationDetails
    (PayPeriodNormalized, CurrencyNormalized, CompensationTypeNormalized, ValidFrom, ValidTo);
GO

CREATE TABLE dbo.DimJob (
    JobSK INT IDENTITY(1,1) PRIMARY KEY,
    JobID BIGINT NOT NULL UNIQUE,
    CompanySK_at_listing INT,
    ExperienceLevelSK INT,
    Title NVARCHAR(500),
    Description NVARCHAR(MAX),
    FormattedWorkType NVARCHAR(50),
    RemoteAllowed BIT,
    JobPostingURL NVARCHAR(1000),
    ApplicationURL NVARCHAR(1000),
    ApplicationType NVARCHAR(50),
    SkillsDesc NVARCHAR(MAX),
    PostingDomain NVARCHAR(255),
    Sponsored BIT,
    WorkType NVARCHAR(50),
    OriginalListedTime_raw DECIMAL(20,0),
    ListedTime_raw DECIMAL(20,0),
    Expiry_raw DECIMAL(20,0),
    ClosedTime_raw DECIMAL(20,0),
    OriginalListedTimestamp DATETIME2,
    ListedTimestamp DATETIME2,
    ExpiryTimestamp DATETIME2,
    ClosedTimestamp DATETIME2,
    FOREIGN KEY (CompanySK_at_listing) REFERENCES dbo.DimCompany(CompanySK),
    FOREIGN KEY (ExperienceLevelSK) REFERENCES dbo.DimExperienceLevel(ExperienceLevelSK)
);
PRINT 'Table DimJob created.';
GO

-- ==========================================================================
-- Bước 3: CREATE các bảng Fact
-- ==========================================================================
PRINT 'Creating Fact Tables...';
GO

CREATE TABLE dbo.FactJobPosting (
    JobPostingID INT IDENTITY(1,1) PRIMARY KEY,
    JobSK INT NOT NULL,
    CompanySK INT NOT NULL,
    LocationSK INT NOT NULL,
    ExperienceLevelSK INT,
    CompensationDetailsSK INT,
    ListedDateSK INT NOT NULL,
    ExpiryDateSK INT,
    ClosedDateSK INT,
    OriginalListedDateSK INT,
    Views BIGINT,
    Applies BIGINT,
    MaxSalary DECIMAL(38,2),
    MinSalary DECIMAL(38,2),
    MedSalary DECIMAL(38,2),
    NormalizedSalary DECIMAL(38,2),
    job_df_MaxSalary DECIMAL(38,2),
    job_df_MinSalary DECIMAL(38,2),
    job_df_MedSalary DECIMAL(38,2),
    job_df_PayPeriod NVARCHAR(50),
    job_df_Currency NVARCHAR(10),
    job_df_CompensationType NVARCHAR(50),
    job_df_NormalizedSalary DECIMAL(38,2),
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (JobSK) REFERENCES dbo.DimJob(JobSK),
    FOREIGN KEY (CompanySK) REFERENCES dbo.DimCompany(CompanySK),
    FOREIGN KEY (LocationSK) REFERENCES dbo.DimLocation(LocationSK),
    FOREIGN KEY (ExperienceLevelSK) REFERENCES dbo.DimExperienceLevel(ExperienceLevelSK),
    FOREIGN KEY (CompensationDetailsSK) REFERENCES dbo.DimCompensationDetails(CompensationDetailsSK),
    FOREIGN KEY (ListedDateSK) REFERENCES dbo.DimDate(DateSK),
    FOREIGN KEY (ExpiryDateSK) REFERENCES dbo.DimDate(DateSK),
    FOREIGN KEY (ClosedDateSK) REFERENCES dbo.DimDate(DateSK),
    FOREIGN KEY (OriginalListedDateSK) REFERENCES dbo.DimDate(DateSK)
);
PRINT 'Table FactJobPosting created.';
GO
CREATE INDEX IDX_FactJobPosting_JobSK ON dbo.FactJobPosting(JobSK);
CREATE INDEX IDX_FactJobPosting_CompanySK ON dbo.FactJobPosting(CompanySK);
CREATE INDEX IDX_FactJobPosting_LocationSK ON dbo.FactJobPosting(LocationSK);
CREATE INDEX IDX_FactJobPosting_ListedDateSK ON dbo.FactJobPosting(ListedDateSK);
GO

CREATE TABLE dbo.FactCompanySnapshot (
    CompanySnapshotSK INT IDENTITY(1,1) PRIMARY KEY,
    SnapshotDateSK INT NULL,
    CompanySK INT NOT NULL,
    EmployeeCount INT,
    FollowerCount INT,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SnapshotDateSK) REFERENCES dbo.DimDate(DateSK),
    FOREIGN KEY (CompanySK) REFERENCES dbo.DimCompany(CompanySK)
);
PRINT 'Table FactCompanySnapshot created.';
GO
CREATE INDEX IDX_FactCompanySnapshot_SnapshotDateSK ON dbo.FactCompanySnapshot(SnapshotDateSK);
CREATE INDEX IDX_FactCompanySnapshot_CompanySK ON dbo.FactCompanySnapshot(CompanySK);
GO

-- ==========================================================================
-- Bước 4: CREATE các bảng Bridge
-- ==========================================================================
PRINT 'Creating Bridge Tables...';
GO

CREATE TABLE dbo.BridgeJobSkill (
    JobSK INT NOT NULL,
    SkillSK INT NOT NULL,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (JobSK, SkillSK),
    FOREIGN KEY (JobSK) REFERENCES dbo.DimJob(JobSK),
    FOREIGN KEY (SkillSK) REFERENCES dbo.DimSkill(SkillSK)
);
PRINT 'Table BridgeJobSkill created.';
GO

CREATE TABLE dbo.BridgeJobIndustry (
    JobSK INT NOT NULL,
    IndustrySK INT NOT NULL,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (JobSK, IndustrySK),
    FOREIGN KEY (JobSK) REFERENCES dbo.DimJob(JobSK),
    FOREIGN KEY (IndustrySK) REFERENCES dbo.DimIndustry(IndustrySK)
);
PRINT 'Table BridgeJobIndustry created.';
GO

CREATE TABLE dbo.BridgeJobBenefit (
    JobSK INT NOT NULL,
    BenefitTypeSK INT NOT NULL,
    IsInferredBenefit BIT,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (JobSK, BenefitTypeSK),
    FOREIGN KEY (JobSK) REFERENCES dbo.DimJob(JobSK),
    FOREIGN KEY (BenefitTypeSK) REFERENCES dbo.DimBenefitType(BenefitTypeSK)
);
PRINT 'Table BridgeJobBenefit created.';
GO

CREATE TABLE dbo.BridgeCompanyIndustry (
    CompanySK INT NOT NULL,
    IndustrySK INT NOT NULL,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (CompanySK, IndustrySK),
    FOREIGN KEY (CompanySK) REFERENCES dbo.DimCompany(CompanySK),
    FOREIGN KEY (IndustrySK) REFERENCES dbo.DimIndustry(IndustrySK)
);
PRINT 'Table BridgeCompanyIndustry created.';
GO

CREATE TABLE dbo.BridgeCompanySpeciality (
    CompanySK INT NOT NULL,
    SpecialitySK INT NOT NULL,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (CompanySK, SpecialitySK),
    FOREIGN KEY (CompanySK) REFERENCES dbo.DimCompany(CompanySK),
    FOREIGN KEY (SpecialitySK) REFERENCES dbo.DimSpeciality(SpecialitySK)
);
PRINT 'Table BridgeCompanySpeciality created.';
GO

PRINT 'All tables for LinkedInDW created successfully with detailed DimDate structure.';
GO