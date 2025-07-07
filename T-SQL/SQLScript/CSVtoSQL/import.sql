USE LinkedInStagingDB;
GO

PRINT 'Starting BULK INSERT operations...';
GO

-- 1. Bảng Staging cho postings.csv (job_postings.csv)
PRINT 'Importing Stg_job_postings...';
-- TRUNCATE TABLE dbo.Stg_job_postings; -- Tùy chọn: Xóa dữ liệu cũ
BEGIN TRY
    BULK INSERT dbo.Stg_job_postings
    FROM 'D:\DW\postings.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\postings_errors.txt' -- Tạo thư mục Logs trước
    );
    PRINT 'Stg_job_postings imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_job_postings:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 2. Bảng Staging cho companies.csv (trong folder companies)
PRINT 'Importing Stg_companies...';
-- TRUNCATE TABLE dbo.Stg_companies;
BEGIN TRY
    BULK INSERT dbo.Stg_companies
    FROM 'D:\DW\companies\companies.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\companies_errors.txt'
    );
    PRINT 'Stg_companies imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_companies:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 3. Bảng Staging cho company_industries.csv (trong folder companies)
PRINT 'Importing Stg_company_industries...';
-- TRUNCATE TABLE dbo.Stg_company_industries;
BEGIN TRY
    BULK INSERT dbo.Stg_company_industries
    FROM 'D:\DW\companies\company_industries.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\company_industries_errors.txt'
    );
    PRINT 'Stg_company_industries imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_company_industries:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 4. Bảng Staging cho company_specialities.csv (trong folder companies)
PRINT 'Importing Stg_company_specialities...';
-- TRUNCATE TABLE dbo.Stg_company_specialities;
BEGIN TRY
    BULK INSERT dbo.Stg_company_specialities
    FROM 'D:\DW\companies\company_specialities.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\company_specialities_errors.txt'
    );
    PRINT 'Stg_company_specialities imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_company_specialities:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 5. Bảng Staging cho employee_counts.csv (trong folder companies)
PRINT 'Importing Stg_employee_counts...';
-- TRUNCATE TABLE dbo.Stg_employee_counts;
BEGIN TRY
    BULK INSERT dbo.Stg_employee_counts
    FROM 'D:\DW\companies\employee_counts.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\employee_counts_errors.txt'
    );
    PRINT 'Stg_employee_counts imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_employee_counts:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 6. Bảng Staging cho benefits.csv (trong folder jobs)
PRINT 'Importing Stg_benefits...';
-- TRUNCATE TABLE dbo.Stg_benefits;
BEGIN TRY
    BULK INSERT dbo.Stg_benefits
    FROM 'D:\DW\jobs\benefits.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\benefits_errors.txt'
    );
    PRINT 'Stg_benefits imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_benefits:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 7. Bảng Staging cho job_industries.csv (trong folder jobs)
PRINT 'Importing Stg_job_industries...';
-- TRUNCATE TABLE dbo.Stg_job_industries;
BEGIN TRY
    BULK INSERT dbo.Stg_job_industries
    FROM 'D:\DW\jobs\job_industries.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\job_industries_errors.txt'
    );
    PRINT 'Stg_job_industries imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_job_industries:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 8. Bảng Staging cho job_skills.csv (trong folder jobs)
PRINT 'Importing Stg_job_skills...';
-- TRUNCATE TABLE dbo.Stg_job_skills;
BEGIN TRY
    BULK INSERT dbo.Stg_job_skills
    FROM 'D:\DW\jobs\job_skills.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\job_skills_errors.txt'
    );
    PRINT 'Stg_job_skills imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_job_skills:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 9. Bảng Staging cho salaries.csv (trong folder jobs)
PRINT 'Importing Stg_salaries...';
-- TRUNCATE TABLE dbo.Stg_salaries;
BEGIN TRY
    BULK INSERT dbo.Stg_salaries
    FROM 'D:\DW\jobs\salaries.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\salaries_errors.txt'
    );
    PRINT 'Stg_salaries imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_salaries:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 10. Bảng Staging cho industries.csv (trong folder mappings)
PRINT 'Importing Stg_industries...';
-- TRUNCATE TABLE dbo.Stg_industries;
BEGIN TRY
    BULK INSERT dbo.Stg_industries
    FROM 'D:\DW\mappings\industries.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\mappings_industries_errors.txt'
    );
    PRINT 'Stg_industries imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_industries:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 11. Bảng Staging cho skills.csv (trong folder mappings)
PRINT 'Importing Stg_skills...';
-- TRUNCATE TABLE dbo.Stg_skills;
BEGIN TRY
    BULK INSERT dbo.Stg_skills
    FROM 'D:\DW\mappings\skills.csv' -- SỬA ĐƯỜNG DẪN NẾU CẦN
    WITH (
        FORMAT = 'CSV',
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIRSTROW = 2,
        TABLOCK,
        BATCHSIZE = 10000,
        MAXERRORS = 1000000,
        CODEPAGE = '65001'
        --,ERRORFILE = 'D:\DW\Logs\mappings_skills_errors.txt'
    );
    PRINT 'Stg_skills imported successfully.';
END TRY
BEGIN CATCH
    PRINT 'ERROR Importing Stg_skills:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

PRINT 'All BULK INSERT operations attempted.';
GO

-- Kiểm tra tổng quan sau khi import
PRINT 'Row counts in staging tables:';
SELECT 'Stg_job_postings' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_job_postings
UNION ALL
SELECT 'Stg_companies' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_companies
UNION ALL
SELECT 'Stg_company_industries' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_company_industries
UNION ALL
SELECT 'Stg_company_specialities' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_company_specialities
UNION ALL
SELECT 'Stg_employee_counts' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_employee_counts
UNION ALL
SELECT 'Stg_benefits' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_benefits
UNION ALL
SELECT 'Stg_job_industries' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_job_industries
UNION ALL
SELECT 'Stg_job_skills' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_job_skills
UNION ALL
SELECT 'Stg_salaries' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_salaries
UNION ALL
SELECT 'Stg_industries' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_industries
UNION ALL
SELECT 'Stg_skills' AS TableName, COUNT(*) AS Row_Count FROM dbo.Stg_skills;
GO