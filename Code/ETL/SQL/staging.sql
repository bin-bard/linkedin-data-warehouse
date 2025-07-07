-- ==========================================================================
-- Script to stage data from various LinkedIn job posting data sources
-- into staging tables for the LinkedIn Data Warehouse
-- ==========================================================================

-- Create staging tables for dimension data
-- ==========================================================================

create database JobDWStage
GO

USE JobDWStage
GO


-- Stage DimCompany
SELECT 
    company_id AS CompanyID,
    name AS Name,
    description AS Description,
    company_size AS CompanySizeRaw,
    state AS State,
    country AS Country,
    city AS City,
    zip_code AS ZipCode,
    address AS Address,
    url AS URL,
    GETDATE() AS SourceTimeRecorded
INTO JobDWStage.dbo.Stg_DimCompany
FROM Job.dbo.companies;

-- Stage DimLocation (derived from job postings)
SELECT DISTINCT
    location AS LocationString,
    CASE WHEN CHARINDEX(',', location) > 0 
         THEN LTRIM(RTRIM(SUBSTRING(location, 1, CHARINDEX(',', location) - 1)))
         ELSE NULL END AS City,
    CASE WHEN CHARINDEX(',', location) > 0 
         THEN LTRIM(RTRIM(SUBSTRING(location, CHARINDEX(',', location) + 1, LEN(location))))
         ELSE NULL END AS State,
    NULL AS Country,
    zip_code AS ZipCode,
    fips AS FIPS
INTO JobDWStage.dbo.Stg_DimLocation
FROM Job.dbo.postings;

--Staging bảng Date 

select * 
into JobDWStage.dbo.Stg_DimDate 
from [Date].[dbo].[Date_Dimension] 
where year between 2023 and 2024 

-- Stage DimSkill
SELECT DISTINCT
    skill_abr AS SkillAbr,
    skill_name AS SkillName
INTO JobDWStage.dbo.Stg_DimSkill
FROM Job.dbo.skills;

-- Stage DimIndustry
SELECT DISTINCT
    industry_id AS IndustryID,
    industry_name AS IndustryName
INTO JobDWStage.dbo.Stg_DimIndustry
FROM Job.dbo.industries;

-- Stage DimExperienceLevel
SELECT DISTINCT
    formatted_experience_level AS FormattedExperienceLevel
INTO JobDWStage.dbo.Stg_DimExperienceLevel
FROM Job.dbo.postings
WHERE formatted_experience_level IS NOT NULL;

-- Stage DimBenefitType
SELECT DISTINCT
    type AS BenefitName
INTO JobDWStage.dbo.Stg_DimBenefitType
FROM Job.dbo.job_benefits;

-- Stage DimSpeciality
SELECT DISTINCT
    speciality AS SpecialityName
INTO JobDWStage.dbo.Stg_DimSpeciality
FROM Job.dbo.company_specialities;

-- Stage DimCompensationDetails
SELECT DISTINCT
    pay_period AS PayPeriod,
    currency AS Currency,
    compensation_type AS CompensationType
INTO JobDWStage.dbo.Stg_DimCompensationDetails
FROM Job.dbo.job_salaries
WHERE pay_period IS NOT NULL 
   OR currency IS NOT NULL 
   OR compensation_type IS NOT NULL;

-- Stage DimJob
SELECT
    p.job_id AS JobID,
    p.company_id AS CompanyID,
    p.title AS Title,
    p.description AS Description,
    p.formatted_work_type AS FormattedWorkType,
    p.remote_allowed AS RemoteAllowed,
    p.job_posting_url AS JobPostingURL,
    p.application_url AS ApplicationURL,
    p.application_type AS ApplicationType,
    p.skills_desc AS SkillsDesc,
    p.posting_domain AS PostingDomain,
    p.sponsored AS Sponsored,
    p.work_type AS WorkType,
    p.original_listed_time AS OriginalListedTime_raw,
    p.listed_time AS ListedTime_raw,
    p.expiry AS Expiry_raw,
    p.closed_time AS ClosedTime_raw,
    p.formatted_experience_level AS FormattedExperienceLevel,
    -- Convert UNIX timestamps to datetime using the scaling factor of 10000
    DATEADD(SECOND, p.original_listed_time / 10000, '1970-01-01') AS OriginalListedTimestamp,
    DATEADD(SECOND, p.listed_time / 10000, '1970-01-01') AS ListedTimestamp,
    DATEADD(SECOND, p.expiry / 10000, '1970-01-01') AS ExpiryTimestamp,
    CASE WHEN p.closed_time IS NOT NULL 
         THEN DATEADD(SECOND, p.closed_time / 10000, '1970-01-01') 
         ELSE NULL END AS ClosedTimestamp
INTO JobDWStage.dbo.Stg_DimJob
FROM Job.dbo.postings p;

-- Create staging tables for fact and bridge data
-- ==========================================================================

-- Stage FactJobPosting
SELECT
    p.job_id AS JobID,
    p.company_id AS CompanyID,
    p.location AS Location,
    p.formatted_experience_level AS FormattedExperienceLevel,
    -- Date keys will be calculated based on the actual DimDate in load.sql
    p.views AS Views,
    p.applies AS Applies,
    p.max_salary AS MaxSalary,
    p.min_salary AS MinSalary,
    p.med_salary AS MedSalary,
    p.normalized_salary AS NormalizedSalary,
    s.max_salary AS job_df_MaxSalary,
    s.min_salary AS job_df_MinSalary,
    s.med_salary AS job_df_MedSalary,
    s.pay_period AS job_df_PayPeriod,
    s.currency AS job_df_Currency,
    s.compensation_type AS job_df_CompensationType,
    -- Convert UNIX timestamps to datetime for later date key lookups using the scaling factor of 10000
    DATEADD(SECOND, p.listed_time / 10000, '1970-01-01') AS ListedTimestamp,
    DATEADD(SECOND, p.expiry / 10000, '1970-01-01') AS ExpiryTimestamp,
    CASE WHEN p.closed_time IS NOT NULL 
         THEN DATEADD(SECOND, p.closed_time / 10000, '1970-01-01') 
         ELSE NULL END AS ClosedTimestamp,
    DATEADD(SECOND, p.original_listed_time / 10000, '1970-01-01') AS OriginalListedTimestamp
INTO JobDWStage.dbo.Stg_FactJobPosting
FROM Job.dbo.postings p
LEFT JOIN Job.dbo.job_salaries s ON p.job_id = s.job_id;

-- Stage FactCompanySnapshot
SELECT
    company_id AS CompanyID,
    employee_count AS EmployeeCount,
    follower_count AS FollowerCount,
    time_recorded AS TimeRecorded_raw,
    DATEADD(SECOND, time_recorded / 10000, '1970-01-01') AS TimeRecordedTimestamp
INTO JobDWStage.dbo.Stg_FactCompanySnapshot
FROM Job.dbo.company_employee_counts;

-- Stage BridgeJobSkill
SELECT
    js.job_id AS JobID,
    js.skill_abr AS SkillAbr
INTO JobDWStage.dbo.Stg_BridgeJobSkill
FROM Job.dbo.job_skills js;

-- Stage BridgeJobIndustry
SELECT
    ji.job_id AS JobID,
    ji.industry_id AS IndustryID
INTO JobDWStage.dbo.Stg_BridgeJobIndustry
FROM Job.dbo.job_industries ji;

-- Stage BridgeJobBenefit
SELECT
    b.job_id AS JobID,
    b.type AS BenefitType,
    b.inferred AS IsInferredBenefit
INTO JobDWStage.dbo.Stg_BridgeJobBenefit
FROM Job.dbo.job_benefits b;

-- Stage BridgeCompanyIndustry
SELECT
    ci.company_id AS CompanyID,
    CASE 
        WHEN TRY_CAST(ci.industry AS INT) IS NOT NULL THEN TRY_CAST(ci.industry AS INT)
        ELSE NULL -- Handle case where industry might not be a valid integer
    END AS IndustryID,
    ci.industry AS IndustryName
INTO JobDWStage.dbo.Stg_BridgeCompanyIndustry
FROM Job.dbo.company_industries ci;

-- Stage BridgeCompanySpeciality
SELECT
    cs.company_id AS CompanyID,
    cs.speciality AS SpecialityName
INTO JobDWStage.dbo.Stg_BridgeCompanySpeciality
FROM Job.dbo.company_specialities cs;
