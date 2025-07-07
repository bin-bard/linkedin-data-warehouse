-- ==========================================================================
-- Script to load data from staging tables to the LinkedIn Data Warehouse
-- Loads dimension tables first, then fact tables, then bridge tables
-- ==========================================================================

USE LinkedInDW;
GO

PRINT 'Starting data load process from staging tables...';
GO

-- ==========================================================================
-- Step 1: Load Dimension Tables
-- ==========================================================================

-- First clear any existing data to avoid primary key violations
PRINT 'Truncating all tables...';
-- Bridge Tables (dependent tables first)
TRUNCATE TABLE dbo.BridgeCompanySpeciality;
TRUNCATE TABLE dbo.BridgeCompanyIndustry;
TRUNCATE TABLE dbo.BridgeJobBenefit;
TRUNCATE TABLE dbo.BridgeJobIndustry;
TRUNCATE TABLE dbo.BridgeJobSkill;
-- Fact Tables
TRUNCATE TABLE dbo.FactJobPosting;
TRUNCATE TABLE dbo.FactCompanySnapshot;
-- Dimension Tables (with proper order for foreign key dependencies)
DELETE FROM dbo.DimJob;
DELETE FROM dbo.DimCompensationDetails;
DELETE FROM dbo.DimSpeciality;
DELETE FROM dbo.DimBenefitType;
DELETE FROM dbo.DimExperienceLevel;
DELETE FROM dbo.DimIndustry;
DELETE FROM dbo.DimSkill;
DELETE FROM dbo.DimLocation;
DELETE FROM dbo.DimCompany;
DELETE FROM dbo.DimDate;
PRINT 'All tables truncated.';
GO

-- Load DimDate (avoiding duplicates)
PRINT 'Loading DimDate...';
INSERT INTO dbo.DimDate (
    DateSK, DateValue, DayOfWeek, DayNumInMonth, DayNumOverall,
    DayName, DayAbbrev, IsWeekend, WeekNumInYear, WeekNumOverall,
    WeekBeginDate, WeekBeginDateKey, Month, MonthNumOverall,
    MonthName, MonthAbbrev, Quarter, Year, YearMonth,
    FiscalMonth, FiscalQuarter, FiscalYear, LastDayInMonthFlag, SameDayYearAgoDate
)
SELECT DISTINCT -- Add DISTINCT to avoid duplicate keys
    date_key AS DateSK,
    full_date AS DateValue,
    day_of_week AS DayOfWeek,
    day_num_in_month AS DayNumInMonth,
    day_num_overall AS DayNumOverall,
    day_name AS DayName,
    day_abbrev AS DayAbbrev,
    CASE WHEN weekday_flag = 'Weekend' THEN 1 ELSE 0 END AS IsWeekend,
    week_num_in_year AS WeekNumInYear,
    week_num_overall AS WeekNumOverall,
    week_begin_date AS WeekBeginDate,
    week_begin_date_key AS WeekBeginDateKey,
    month AS Month,
    month_num_overall AS MonthNumOverall,
    month_name AS MonthName,
    month_abbrev AS MonthAbbrev,
    quarter AS Quarter,
    year AS Year,
    yearmo AS YearMonth,
    fiscal_month AS FiscalMonth,
    fiscal_quarter AS FiscalQuarter,
    fiscal_year AS FiscalYear,
    CASE WHEN last_day_in_month_flag = 'LastDay' THEN 1 ELSE 0 END AS LastDayInMonthFlag,
    same_day_year_ago_date AS SameDayYearAgoDate
FROM JobDWStage.dbo.Stg_DimDate;
PRINT 'DimDate loaded.';
GO

-- Load DimCompany
PRINT 'Loading DimCompany...';
INSERT INTO dbo.DimCompany (
    CompanyID, Name, Description, CompanySizeRaw,
    State, Country, City, ZipCode, Address, URL,
    EmployeeCount, FollowerCount, SourceTimeRecorded,
    ValidFrom, ValidTo, IsCurrent
)
SELECT
    c.CompanyID,
    c.Name,
    c.Description,
    c.CompanySizeRaw,
    c.State,
    c.Country,
    c.City,
    c.ZipCode,
    c.Address,
    c.URL,
    s.EmployeeCount,
    s.FollowerCount,
    c.SourceTimeRecorded,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimCompany c
LEFT JOIN (
    SELECT 
        CompanyID, 
        MAX(EmployeeCount) AS EmployeeCount, 
        MAX(FollowerCount) AS FollowerCount
    FROM JobDWStage.dbo.Stg_FactCompanySnapshot
    GROUP BY CompanyID
) s ON c.CompanyID = s.CompanyID;
PRINT 'DimCompany loaded.';
GO

-- Load DimLocation
PRINT 'Loading DimLocation...';
INSERT INTO dbo.DimLocation (
    LocationString, City, State, Country, ZipCode, FIPS,
    ValidFrom, ValidTo, IsCurrent
)
SELECT DISTINCT -- Using DISTINCT to avoid duplicates
    LocationString,
    City,
    State,
    Country,
    ZipCode,
    FIPS,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimLocation
WHERE LocationString IS NOT NULL;
PRINT 'DimLocation loaded.';
GO

-- Load DimSkill
PRINT 'Loading DimSkill...';
INSERT INTO dbo.DimSkill (
    SkillAbr, SkillName, ValidFrom, ValidTo, IsCurrent
)
-- Using a derived table with GROUP BY to handle duplicates
SELECT 
    SkillAbr,
    MAX(SkillName) AS SkillName, -- Take the maximum for duplicate skill names
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimSkill
WHERE SkillAbr IS NOT NULL
GROUP BY SkillAbr; -- Group by the unique key to eliminate duplicates
PRINT 'DimSkill loaded.';
GO

-- Load DimIndustry
PRINT 'Loading DimIndustry...';
INSERT INTO dbo.DimIndustry (
    IndustryID, IndustryName, ValidFrom, ValidTo, IsCurrent
)
-- Using a derived table with GROUP BY to handle duplicates
SELECT 
    IndustryID,
    MAX(IndustryName) AS IndustryName, -- Take the maximum for duplicate industry names
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimIndustry
WHERE IndustryID IS NOT NULL
GROUP BY IndustryID; -- Group by the unique key to eliminate duplicates
PRINT 'DimIndustry loaded.';
GO

-- Load DimExperienceLevel
PRINT 'Loading DimExperienceLevel...';
INSERT INTO dbo.DimExperienceLevel (
    FormattedExperienceLevel, ValidFrom, ValidTo, IsCurrent
)
-- Using DISTINCT to handle duplicates
SELECT DISTINCT
    FormattedExperienceLevel,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimExperienceLevel
WHERE FormattedExperienceLevel IS NOT NULL;
PRINT 'DimExperienceLevel loaded.';
GO

-- Load DimBenefitType
PRINT 'Loading DimBenefitType...';
INSERT INTO dbo.DimBenefitType (
    BenefitName, ValidFrom, ValidTo, IsCurrent
)
-- Using DISTINCT to handle duplicates
SELECT DISTINCT
    BenefitName,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimBenefitType
WHERE BenefitName IS NOT NULL;
PRINT 'DimBenefitType loaded.';
GO

-- Load DimSpeciality
PRINT 'Loading DimSpeciality...';
INSERT INTO dbo.DimSpeciality (
    SpecialityName, ValidFrom, ValidTo, IsCurrent
)
-- Using DISTINCT to handle duplicates
SELECT DISTINCT
    SpecialityName,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimSpeciality
WHERE SpecialityName IS NOT NULL;
PRINT 'DimSpeciality loaded.';
GO

-- Load DimCompensationDetails
PRINT 'Loading DimCompensationDetails...';
INSERT INTO dbo.DimCompensationDetails (
    PayPeriod, Currency, CompensationType, ValidFrom, ValidTo, IsCurrent
)
-- Using DISTINCT to handle duplicates
SELECT DISTINCT
    PayPeriod,
    Currency,
    CompensationType,
    GETDATE() AS ValidFrom,
    '9999-12-31' AS ValidTo,
    1 AS IsCurrent
FROM JobDWStage.dbo.Stg_DimCompensationDetails;
PRINT 'DimCompensationDetails loaded.';
GO

-- Load DimJob - Fix arithmetic overflow by handling NULL values and setting defaults instead
PRINT 'Loading DimJob...';
INSERT INTO dbo.DimJob (
    JobID, CompanySK_at_listing, ExperienceLevelSK, Title, Description,
    FormattedWorkType, RemoteAllowed, JobPostingURL, ApplicationURL,
    ApplicationType, SkillsDesc, PostingDomain, Sponsored, WorkType,
    OriginalListedTime_raw, ListedTime_raw, Expiry_raw, ClosedTime_raw,
    OriginalListedTimestamp, ListedTimestamp, ExpiryTimestamp, ClosedTimestamp
)
SELECT 
    j.JobID,
    c.CompanySK AS CompanySK_at_listing,
    e.ExperienceLevelSK,
    j.Title,
    j.Description,
    j.FormattedWorkType,
    j.RemoteAllowed,
    j.JobPostingURL,
    j.ApplicationURL,
    j.ApplicationType,
    j.SkillsDesc,
    j.PostingDomain,
    j.Sponsored,
    j.WorkType,
    -- Convert to decimal(20,0) to handle very large numbers
    CASE 
        WHEN j.OriginalListedTime_raw IS NULL THEN NULL
        ELSE CAST(j.OriginalListedTime_raw AS decimal(20,0))
    END,
    CASE 
        WHEN j.ListedTime_raw IS NULL THEN NULL
        ELSE CAST(j.ListedTime_raw AS decimal(20,0))
    END,
    CASE 
        WHEN j.Expiry_raw IS NULL THEN NULL
        ELSE CAST(j.Expiry_raw AS decimal(20,0))
    END,
    CASE 
        WHEN j.ClosedTime_raw IS NULL THEN NULL
        ELSE CAST(j.ClosedTime_raw AS decimal(20,0))
    END,
    j.OriginalListedTimestamp,
    j.ListedTimestamp,
    j.ExpiryTimestamp,
    j.ClosedTimestamp
FROM JobDWStage.dbo.Stg_DimJob j
LEFT JOIN dbo.DimCompany c ON j.CompanyID = c.CompanyID AND c.IsCurrent = 1
LEFT JOIN dbo.DimExperienceLevel e ON j.FormattedExperienceLevel = e.FormattedExperienceLevel AND e.IsCurrent = 1;
PRINT 'DimJob loaded.';
GO

-- ==========================================================================
-- Step 2: Load Fact Tables
-- ==========================================================================

-- Load FactJobPosting
PRINT 'Loading FactJobPosting...';
INSERT INTO dbo.FactJobPosting (
    JobSK, CompanySK, LocationSK, ExperienceLevelSK, CompensationDetailsSK,
    ListedDateSK, ExpiryDateSK, ClosedDateSK, OriginalListedDateSK,
    Views, Applies, MaxSalary, MinSalary, MedSalary, NormalizedSalary,
    job_df_MaxSalary, job_df_MinSalary, job_df_MedSalary, 
    job_df_PayPeriod, job_df_Currency, job_df_CompensationType, job_df_NormalizedSalary
)
SELECT
    j.JobSK,
    c.CompanySK,
    l.LocationSK,
    e.ExperienceLevelSK,
    cd.CompensationDetailsSK,
    -- Make sure date keys exist in DimDate
    d1.DateSK AS ListedDateSK,
    d2.DateSK AS ExpiryDateSK,
    d3.DateSK AS ClosedDateSK,
    d4.DateSK AS OriginalListedDateSK,
    f.Views,
    f.Applies,
    f.MaxSalary,
    f.MinSalary,
    f.MedSalary,
    f.NormalizedSalary,
    f.job_df_MaxSalary,
    f.job_df_MinSalary,
    f.job_df_MedSalary,
    f.job_df_PayPeriod,
    f.job_df_Currency,
    f.job_df_CompensationType,
    NULL AS job_df_NormalizedSalary
FROM JobDWStage.dbo.Stg_FactJobPosting f
INNER JOIN dbo.DimJob j ON f.JobID = j.JobID
INNER JOIN dbo.DimCompany c ON c.CompanyID = f.CompanyID AND c.IsCurrent = 1
LEFT JOIN dbo.DimLocation l ON l.LocationString = f.Location AND l.IsCurrent = 1
LEFT JOIN dbo.DimExperienceLevel e ON e.FormattedExperienceLevel = f.FormattedExperienceLevel AND e.IsCurrent = 1
LEFT JOIN dbo.DimCompensationDetails cd ON 
    ISNULL(cd.PayPeriod, 'N/A') = ISNULL(f.job_df_PayPeriod, 'N/A') AND
    ISNULL(cd.Currency, 'N/A') = ISNULL(f.job_df_Currency, 'N/A') AND
    ISNULL(cd.CompensationType, 'N/A') = ISNULL(f.job_df_CompensationType, 'N/A') AND
    cd.IsCurrent = 1
-- Join with DimDate to ensure date keys exist
LEFT JOIN dbo.DimDate d1 ON d1.DateValue = CAST(f.ListedTimestamp AS DATE)
LEFT JOIN dbo.DimDate d2 ON d2.DateValue = CAST(f.ExpiryTimestamp AS DATE)
LEFT JOIN dbo.DimDate d3 ON d3.DateValue = CAST(f.ClosedTimestamp AS DATE)
LEFT JOIN dbo.DimDate d4 ON d4.DateValue = CAST(f.OriginalListedTimestamp AS DATE)
-- Only load records with valid date keys
WHERE d1.DateSK IS NOT NULL;
PRINT 'FactJobPosting loaded.';
GO

-- Load FactCompanySnapshot
PRINT 'Loading FactCompanySnapshot...';
INSERT INTO dbo.FactCompanySnapshot (
    SnapshotDateSK, CompanySK, EmployeeCount, FollowerCount
)
SELECT
    d.DateSK AS SnapshotDateSK,
    c.CompanySK,
    s.EmployeeCount,
    s.FollowerCount
FROM JobDWStage.dbo.Stg_FactCompanySnapshot s
INNER JOIN dbo.DimCompany c ON s.CompanyID = c.CompanyID AND c.IsCurrent = 1
-- Join with DimDate to ensure the date key exists
LEFT JOIN dbo.DimDate d ON d.DateValue = CAST(s.TimeRecordedTimestamp AS DATE);
PRINT 'FactCompanySnapshot loaded.';
GO

-- ==========================================================================
-- Step 3: Load Bridge Tables
-- ==========================================================================

-- Load BridgeJobSkill
PRINT 'Loading BridgeJobSkill...';
INSERT INTO dbo.BridgeJobSkill (
    JobSK, SkillSK
)
SELECT DISTINCT -- Use DISTINCT to avoid duplicates
    j.JobSK,
    s.SkillSK
FROM JobDWStage.dbo.Stg_BridgeJobSkill b
INNER JOIN dbo.DimJob j ON b.JobID = j.JobID
INNER JOIN dbo.DimSkill s ON b.SkillAbr = s.SkillAbr AND s.IsCurrent = 1;
PRINT 'BridgeJobSkill loaded.';
GO

-- Load BridgeJobIndustry
PRINT 'Loading BridgeJobIndustry...';
INSERT INTO dbo.BridgeJobIndustry (
    JobSK, IndustrySK
)
SELECT DISTINCT -- Use DISTINCT to avoid duplicates
    j.JobSK,
    i.IndustrySK
FROM JobDWStage.dbo.Stg_BridgeJobIndustry b
INNER JOIN dbo.DimJob j ON b.JobID = j.JobID
INNER JOIN dbo.DimIndustry i ON b.IndustryID = i.IndustryID AND i.IsCurrent = 1;
PRINT 'BridgeJobIndustry loaded.';
GO

-- Load BridgeJobBenefit
PRINT 'Loading BridgeJobBenefit...';
INSERT INTO dbo.BridgeJobBenefit (
    JobSK, BenefitTypeSK, IsInferredBenefit
)
SELECT DISTINCT -- Use DISTINCT to avoid duplicates
    j.JobSK,
    bt.BenefitTypeSK,
    b.IsInferredBenefit
FROM JobDWStage.dbo.Stg_BridgeJobBenefit b
INNER JOIN dbo.DimJob j ON b.JobID = j.JobID
INNER JOIN dbo.DimBenefitType bt ON b.BenefitType = bt.BenefitName AND bt.IsCurrent = 1;
PRINT 'BridgeJobBenefit loaded.';
GO

-- Load BridgeCompanyIndustry
PRINT 'Loading BridgeCompanyIndustry...';
INSERT INTO dbo.BridgeCompanyIndustry (
    CompanySK, IndustrySK
)
SELECT DISTINCT -- Use DISTINCT to avoid duplicates
    c.CompanySK,
    i.IndustrySK
FROM JobDWStage.dbo.Stg_BridgeCompanyIndustry b
INNER JOIN dbo.DimCompany c ON b.CompanyID = c.CompanyID AND c.IsCurrent = 1
INNER JOIN dbo.DimIndustry i ON b.IndustryID = i.IndustryID AND i.IsCurrent = 1
WHERE b.IndustryID IS NOT NULL;
PRINT 'BridgeCompanyIndustry loaded.';
GO

-- Load BridgeCompanySpeciality - Fix the CTE syntax error
PRINT 'Loading BridgeCompanySpeciality...';
-- Need a semicolon before WITH to fix the syntax error
;WITH CompanySpecialityCTE AS (
    SELECT
        c.CompanySK,
        s.SpecialitySK,
        ROW_NUMBER() OVER (PARTITION BY c.CompanySK, s.SpecialitySK ORDER BY c.CompanySK) AS RowNum
    FROM JobDWStage.dbo.Stg_BridgeCompanySpeciality b
    INNER JOIN dbo.DimCompany c ON b.CompanyID = c.CompanyID AND c.IsCurrent = 1
    INNER JOIN dbo.DimSpeciality s ON b.SpecialityName = s.SpecialityName AND s.IsCurrent = 1
)
INSERT INTO dbo.BridgeCompanySpeciality (CompanySK, SpecialitySK)
SELECT
    CompanySK,
    SpecialitySK
FROM CompanySpecialityCTE
WHERE RowNum = 1; -- Only take the first occurrence of each combination
PRINT 'BridgeCompanySpeciality loaded.';
GO

PRINT 'Data load complete!';
GO
