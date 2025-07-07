USE master;
GO

-- Kiểm tra xem database staging đã tồn tại chưa
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'LinkedInStagingDB')
BEGIN
    CREATE DATABASE LinkedInStagingDB;
    PRINT 'Database LinkedInStagingDB created.';
END
ELSE
BEGIN
    PRINT 'Database LinkedInStagingDB already exists.';
END
GO

USE LinkedInStagingDB;
GO

-- Bảng Staging cho postings.csv (đổi tên thành job_postings theo mô tả)
IF OBJECT_ID('dbo.Stg_job_postings', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_job_postings;
GO
CREATE TABLE dbo.Stg_job_postings (
    job_id NVARCHAR(MAX) NULL,
    company_name NVARCHAR(MAX) NULL,
    title NVARCHAR(MAX) NULL,
    description NVARCHAR(MAX) NULL,
    max_salary NVARCHAR(MAX) NULL, -- Để NVARCHAR(MAX) vì có thể có ký tự tiền tệ, dấu phẩy
    pay_period NVARCHAR(MAX) NULL,
    location NVARCHAR(MAX) NULL,
    company_id NVARCHAR(MAX) NULL,
    views NVARCHAR(MAX) NULL,
    med_salary NVARCHAR(MAX) NULL,
    min_salary NVARCHAR(MAX) NULL,
    formatted_work_type NVARCHAR(MAX) NULL,
    applies NVARCHAR(MAX) NULL,
    original_listed_time NVARCHAR(MAX) NULL, -- Epoch time, để NVARCHAR(MAX) trước
    remote_allowed NVARCHAR(MAX) NULL,
    job_posting_url NVARCHAR(MAX) NULL,
    application_url NVARCHAR(MAX) NULL,
    application_type NVARCHAR(MAX) NULL,
    expiry NVARCHAR(MAX) NULL, -- Có thể là ngày hoặc epoch time
    closed_time NVARCHAR(MAX) NULL, -- Epoch time
    formatted_experience_level NVARCHAR(MAX) NULL,
    skills_desc NVARCHAR(MAX) NULL,
    listed_time NVARCHAR(MAX) NULL, -- Epoch time
    posting_domain NVARCHAR(MAX) NULL,
    sponsored NVARCHAR(MAX) NULL,
    work_type NVARCHAR(MAX) NULL,
    currency NVARCHAR(MAX) NULL,
    compensation_type NVARCHAR(MAX) NULL,
    normalized_salary NVARCHAR(MAX) NULL,
    zip_code NVARCHAR(MAX) NULL,
    fips NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_job_postings created.';
GO

-- Bảng Staging cho companies.csv (trong folder companies)
IF OBJECT_ID('dbo.Stg_companies', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_companies;
GO
CREATE TABLE dbo.Stg_companies (
    company_id NVARCHAR(MAX) NULL,
    name NVARCHAR(MAX) NULL,
    description NVARCHAR(MAX) NULL,
    company_size NVARCHAR(MAX) NULL, -- Số 0-7
    state NVARCHAR(MAX) NULL,
    country NVARCHAR(MAX) NULL,
    city NVARCHAR(MAX) NULL,
    zip_code NVARCHAR(MAX) NULL,
    address NVARCHAR(MAX) NULL,
    url NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_companies created.';
GO

-- Bảng Staging cho company_industries.csv (trong folder companies)
IF OBJECT_ID('dbo.Stg_company_industries', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_company_industries;
GO
CREATE TABLE dbo.Stg_company_industries (
    company_id NVARCHAR(MAX) NULL,
    industry NVARCHAR(MAX) NULL -- Đây là tên ngành, không phải ID
);
PRINT 'Table Stg_company_industries created.';
GO

-- Bảng Staging cho company_specialities.csv (trong folder companies)
IF OBJECT_ID('dbo.Stg_company_specialities', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_company_specialities;
GO
CREATE TABLE dbo.Stg_company_specialities (
    company_id NVARCHAR(MAX) NULL,
    speciality NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_company_specialities created.';
GO

-- Bảng Staging cho employee_counts.csv (trong folder companies)
IF OBJECT_ID('dbo.Stg_employee_counts', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_employee_counts;
GO
CREATE TABLE dbo.Stg_employee_counts (
    company_id NVARCHAR(MAX) NULL,
    employee_count NVARCHAR(MAX) NULL,
    follower_count NVARCHAR(MAX) NULL,
    time_recorded NVARCHAR(MAX) NULL -- Unix time (epoch)
);
PRINT 'Table Stg_employee_counts created.';
GO

-- Bảng Staging cho benefits.csv (trong folder jobs)
IF OBJECT_ID('dbo.Stg_benefits', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_benefits;
GO
CREATE TABLE dbo.Stg_benefits (
    job_id NVARCHAR(MAX) NULL,
    inferred NVARCHAR(MAX) NULL, -- Có thể là boolean/bit
    type NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_benefits created.';
GO

-- Bảng Staging cho job_industries.csv (trong folder jobs)
IF OBJECT_ID('dbo.Stg_job_industries', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_job_industries;
GO
CREATE TABLE dbo.Stg_job_industries (
    job_id NVARCHAR(MAX) NULL,
    industry_id NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_job_industries created.';
GO

-- Bảng Staging cho job_skills.csv (trong folder jobs)
IF OBJECT_ID('dbo.Stg_job_skills', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_job_skills;
GO
CREATE TABLE dbo.Stg_job_skills (
    job_id NVARCHAR(MAX) NULL,
    skill_abr NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_job_skills created.';
GO

-- Bảng Staging cho salaries.csv (trong folder jobs)
IF OBJECT_ID('dbo.Stg_salaries', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_salaries;
GO
CREATE TABLE dbo.Stg_salaries (
    salary_id NVARCHAR(MAX) NULL,
    job_id NVARCHAR(MAX) NULL,
    max_salary NVARCHAR(MAX) NULL,
    med_salary NVARCHAR(MAX) NULL,
    min_salary NVARCHAR(MAX) NULL,
    pay_period NVARCHAR(MAX) NULL,
    currency NVARCHAR(MAX) NULL,
    compensation_type NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_salaries created.';
GO

-- Bảng Staging cho industries.csv (trong folder mappings)
IF OBJECT_ID('dbo.Stg_industries', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_industries;
GO
CREATE TABLE dbo.Stg_industries (
    industry_id NVARCHAR(MAX) NULL,
    industry_name NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_industries created.';
GO

-- Bảng Staging cho skills.csv (trong folder mappings)
IF OBJECT_ID('dbo.Stg_skills', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_skills;
GO
CREATE TABLE dbo.Stg_skills (
    skill_abr NVARCHAR(MAX) NULL,
    skill_name NVARCHAR(MAX) NULL
);
PRINT 'Table Stg_skills created.';
GO
