--------------------------------------------------------------------
-- Bước 1: Tạo bảng Stg_DimDate trong LinkedInStagingDB (Không thay đổi)
--------------------------------------------------------------------
USE LinkedInStagingDB;
GO

IF OBJECT_ID('dbo.Stg_DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_DimDate;
GO

CREATE TABLE dbo.Stg_DimDate (
    date_key INT NOT NULL,
    full_date SMALLDATETIME NULL,
    day_of_week TINYINT NULL,
    day_num_in_month TINYINT NULL,
    day_num_overall SMALLINT NULL,
    day_name VARCHAR(9) NULL,
    day_abbrev CHAR(3) NULL,
    weekday_flag VARCHAR(10) NULL,
    week_num_in_year TINYINT NULL,
    week_num_overall SMALLINT NULL,
    week_begin_date SMALLDATETIME NULL,
    week_begin_date_key INT NULL,
    month TINYINT NULL,
    month_num_overall SMALLINT NULL,
    month_name VARCHAR(9) NULL,
    month_abbrev CHAR(3) NULL,
    quarter TINYINT NULL,
    year INT NULL,
    yearmo INT NULL,
    fiscal_month TINYINT NULL,
    fiscal_quarter TINYINT NULL,
    fiscal_year INT NULL,
    last_day_in_month_flag VARCHAR(20) NULL,
    same_day_year_ago_date SMALLDATETIME NULL
);
PRINT 'Table Stg_DimDate created in LinkedInStagingDB.';
GO

--------------------------------------------------------------------
-- Bước 2: Sao chép (Staging) dữ liệu từ Temp.dbo.DimDate
--          sang LinkedInStagingDB.dbo.Stg_DimDate
--------------------------------------------------------------------
USE LinkedInStagingDB; -- Đảm bảo đang ở đúng database
GO

-- Xóa dữ liệu cũ trong bảng staging trước khi load mới (quan trọng)
TRUNCATE TABLE dbo.Stg_DimDate;
PRINT 'Old data truncated from Stg_DimDate.';
GO

-- THAY ĐỔI GIÁ TRỊ Ở ĐÂY:
DECLARE @StartYear INT = 2023; -- Năm bắt đầu muốn staging
DECLARE @EndYear INT = 2024;   -- Năm kết thúc muốn staging

PRINT 'Staging data into Stg_DimDate for years ' + CONVERT(VARCHAR, @StartYear) + ' to ' + CONVERT(VARCHAR, @EndYear) + '...';

INSERT INTO dbo.Stg_DimDate (
    date_key, full_date, day_of_week, day_num_in_month, day_num_overall, day_name, day_abbrev,
    weekday_flag, week_num_in_year, week_num_overall, week_begin_date, week_begin_date_key,
    month, month_num_overall, month_name, month_abbrev, quarter, year, yearmo,
    fiscal_month, fiscal_quarter, fiscal_year, last_day_in_month_flag, same_day_year_ago_date
)
SELECT
    date_key, full_date, day_of_week, day_num_in_month, day_num_overall, day_name, day_abbrev,
    weekday_flag, week_num_in_year, week_num_overall, week_begin_date, week_begin_date_key,
    month, month_num_overall, month_name, month_abbrev, quarter, year, yearmo,
    fiscal_month, fiscal_quarter, fiscal_year, last_day_in_month_flag, same_day_year_ago_date
FROM Temp.dbo.DimDate -- ĐẢM BẢO DATABASE 'Temp' VÀ BẢNG 'DimDate' TỒN TẠI VÀ CÓ DỮ LIỆU
WHERE year >= @StartYear AND year <= @EndYear; -- Lọc theo khoảng thời gian cần thiết

PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' rows staged into Stg_DimDate.';
GO

-- Kiểm tra
SELECT TOP 10 * FROM dbo.Stg_DimDate ORDER BY date_key;
SELECT COUNT(*) FROM dbo.Stg_DimDate;
GO