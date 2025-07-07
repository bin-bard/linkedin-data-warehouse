# LinkedIn Data Warehouse

## Project Overview

This project builds a comprehensive **Enterprise Data Warehouse** for analyzing LinkedIn job market data using industry-standard methodologies and Microsoft SQL Server technology stack. The system implements a complete end-to-end business intelligence solution following Kimball dimensional modeling methodology.

![LinkedIn Data Warehouse Architecture](./image/LinkedIn%20Data%20Warehouse%20-%20Enterprise%20ETL%20Architecture.png)

### **KEY OBJECTIVES**

- Build a centralized data warehouse for LinkedIn job market analysis
- Implement dimensional modeling using Kimball methodology
- Design and deploy robust ETL processes with SSIS and T-SQL
- Create multidimensional OLAP cubes with SSAS for fast analytics
- Enable business intelligence reporting and self-service analytics
- Analyze recruitment trends, salary patterns, and skill demand

### **BUSINESS DOMAIN**

**Job Market Intelligence and Recruitment Analytics** covering:

- **Job Postings Analysis**: Trends, patterns, and market dynamics
- **Company Intelligence**: Organization profiles, size, and hiring patterns
- **Compensation Analysis**: Salary ranges, benefits, and compensation trends
- **Skills Intelligence**: In-demand skills, emerging technologies, skill gaps
- **Geographic Analysis**: Location-based job distribution and remote work trends
- **Industry Analysis**: Sector-specific hiring patterns and growth areas

## **METHODOLOGY & DESIGN APPROACH**

### **Kimball Dimensional Modeling Methodology**

This project strictly follows **Ralph Kimball's** dimensional modeling methodology using professional design workbooks:

#### **Design Documentation** (`./Design/`)

- **`High-Level-Dimensional-Modeling-Workbook.xlsx`**: Strategic business requirements and high-level dimensional model design
- **`Detailed-Dimensional-Modeling-Workbook-KimballU.xlsm`**: Comprehensive Kimball University methodology implementation with detailed specifications

#### **Kimball Design Process Applied**

1. **Business Process Definition**

   - Identified core business processes: Job Posting, Company Snapshot
   - Defined grain for each fact table (one row per job posting, one row per company per time period)
2. **Bus Architecture Development**

   - Created enterprise data warehouse bus matrix
   - Designed conformed dimensions for enterprise scalability
   - Established common business definitions
3. **Dimensional Model Design**

   - Implemented Star Schema with proper fact and dimension separation
   - Applied Slowly Changing Dimension (SCD) Type 2 for historical tracking
   - Created bridge tables for many-to-many relationships
4. **Physical Design Optimization**

   - Designed surrogate keys for all dimensions
   - Implemented proper indexing strategy
   - Optimized for query performance

## **SYSTEM ARCHITECTURE**

### **DIMENSIONAL MODEL - Star Schema Implementation**

#### **Fact Tables**

- **`FactJobPosting`** - Grain: One row per job posting
  - Measures: Views, Applies, Salary metrics, Duration
  - Foreign Keys: JobSK, CompanySK, LocationSK, PostedDateSK
- **`FactCompanySnapshot`** - Grain: One row per company per snapshot date
  - Measures: Employee count, Follower count
  - Foreign Keys: CompanySK, SnapshotDateSK

#### **Dimension Tables (SCD Type 2 Implementation)**

- **`DimDate`** - Kimball-style time dimension with fiscal and calendar hierarchies
- **`DimCompany`** - Company master data with historical tracking
- **`DimJob`** - Job details and characteristics
- **`DimLocation`** - Geographic information with normalization
- **`DimSkill`** - Skills taxonomy and categorization
- **`DimIndustry`** - Industry classification (NAICS-based)
- **`DimExperienceLevel`** - Experience requirements taxonomy
- **`DimBenefitType`** - Benefits categorization
- **`DimSpeciality`** - Company specialization areas
- **`DimCompensationDetails`** - Compensation structure details

#### **Bridge Tables (Many-to-Many Relationships)**

- **`BridgeJobSkill`** - Jobs ↔ Required Skills
- **`BridgeJobIndustry`** - Jobs ↔ Industry Classifications
- **`BridgeJobBenefit`** - Jobs ↔ Offered Benefits
- **`BridgeCompanyIndustry`** - Companies ↔ Industry Focus
- **`BridgeCompanySpeciality`** - Companies ↔ Specialization Areas

### **ETL PIPELINE ARCHITECTURE**

#### **Three-Layer Architecture**

1. **Extract Layer**: Raw data from CSV files (515MB+ total dataset)
2. **Transform & Staging Layer**: Data cleansing, business rules, validation
3. **Load Layer**: Dimensional model population with SCD processing

#### **ETL Process Implementation**

- **Bulk Copy Program (BCP)**: High-performance data import from CSV files
- **Staging Database**: `JobDWStage` for data transformation and validation
- **SSIS Packages**: Enterprise ETL orchestration
  - `Load_DimDate.dtsx`: Time dimension population
  - `Load_Dimensions.dtsx`: All dimension tables with SCD Type 2 processing
  - `Load_Facts.dtsx`: Fact table loading with referential integrity
- **SQL Server Agent**: Job scheduling and dependency management

## **PROJECT STRUCTURE**

```
LinkedIn Data Warehouse/
├── Data/                     # Source data (515MB+ total)
│   └── Dataset/
│       ├── companies/           # Company data (28MB+)
│       │   ├── companies.csv           # Master company data (22MB)
│       │   ├── company_industries.csv  # Company-industry mapping (764KB)
│       │   ├── company_specialities.csv # Company specializations (4.2MB)
│       │   └── employee_counts.csv     # Historical employee counts (1MB)
│       ├── jobs/                # Job-related data (10MB+)
│       │   ├── benefits.csv            # Job benefits data (1.8MB)
│       │   ├── job_industries.csv      # Job-industry relationships (2.4MB)
│       │   ├── job_skills.csv          # Job-skill requirements (3.3MB)
│       │   └── salaries.csv            # Compensation data (2.1MB)
│       ├── mappings/            # Reference data
│       │   ├── skills.csv              # Skills taxonomy (679B)
│       │   └── industries.csv          # Industry classifications (12KB)
│       └── postings.csv         # Main dataset (493MB)
├── Code/                     # Implementation code
│   ├── ETL/
│   │   ├── SQL/                 # T-SQL ETL scripts
│   │   │   ├── staging.sql             # Staging layer creation
│   │   │   ├── dwh.sql                 # Data warehouse schema
│   │   │   ├── load.sql                # Data loading procedures
│   │   │   └── create-dimdate.sql      # Date dimension setup
│   │   └── SSIS/                # SQL Server Integration Services
│   │       └── NguyenThanhTai_22133049_LinkedIn_ETL/
│   │           ├── Load_DimDate.dtsx
│   │           ├── Load_Dimensions.dtsx
│   │           └── Load_Facts.dtsx
│   └── SSAS/                    # SQL Server Analysis Services
│       └── DWProject/           # OLAP cube implementation
│           ├── Job DW.cube             # Main analytical cube
│           ├── Final Proj DW.dsv       # Data source view
│           └── [Multiple dimension files]
├── Design/                   # Methodology & Design Documents
│   ├── High-Level-Dimensional-Modeling-Workbook.xlsx
│   └── Detailed-Dimensional-Modeling-Workbook-KimballU.xlsm
├── image/                    # Architecture diagrams
│   └── LinkedIn Data Warehouse - Enterprise ETL Architecture.png
├── T-SQL/                    # Additional SQL utilities
│   └── SQLScript/
│       ├── LinkedInDW.sql              # Main DW schema script
│       ├── DBStaging.sql               # Staging database setup
│       ├── CSVtoSQL/                   # Data import utilities
│       └── DimDate/                    # Date dimension scripts
└── README.md                    # This documentation
```

## **TECHNOLOGY STACK**

### **Microsoft SQL Server Ecosystem**

- **Database Engine**: SQL Server 2019+ (Raw data, Staging, Data Warehouse)
- **Integration Services (SSIS)**: ETL orchestration and data flow
- **Analysis Services (SSAS)**: Multidimensional OLAP cubes
- **SQL Server Agent**: Job scheduling and automation
- **T-SQL**: Stored procedures and data transformation logic

### **Development & Design Tools**

- **SQL Server Management Studio (SSMS)**: Database administration
- **SQL Server Data Tools (SSDT)**: SSIS and SSAS development
- **Microsoft Excel**: Kimball methodology design workbooks
- **Visual Studio**: Integrated development environment

### **Data Processing**

- **Bulk Copy Program (BCP)**: High-performance data import
- **Staging Architecture**: Three-tier ETL implementation
- **Surrogate Key Management**: Automated key generation
- **SCD Type 2 Processing**: Historical data preservation

## **DEPLOYMENT GUIDE**

### **1. Environment Setup**

```sql
-- Create required databases
CREATE DATABASE Job;          -- Raw data storage
CREATE DATABASE JobDWStage;   -- ETL staging area
CREATE DATABASE LinkedInDW;   -- Production data warehouse
CREATE DATABASE [Date];       -- Date dimension helper
```

### **2. Data Import Process**

```bash
# Navigate to Data/Dataset/ directory
# Import main dataset
bcp Job.dbo.postings in "postings.csv" -T -c -t"," -r"\n" -F2

# Import company data
bcp Job.dbo.companies in "companies/companies.csv" -T -c -t"," -r"\n" -F2

# Import additional datasets
# [Continue with other CSV files...]
```

### **3. ETL Implementation**

```sql
-- Execute staging layer creation
sqlcmd -S server -d JobDWStage -i "Code/ETL/SQL/staging.sql"

-- Create data warehouse schema
sqlcmd -S server -d LinkedInDW -i "Code/ETL/SQL/dwh.sql"

-- Execute initial data load
sqlcmd -S server -d LinkedInDW -i "Code/ETL/SQL/load.sql"
```

### **4. SSIS Package Deployment**

1. Open Visual Studio with SQL Server Data Tools
2. Deploy SSIS project: `Code/ETL/SSIS/NguyenThanhTai_22133049_LinkedIn_ETL/`
3. Configure connection managers for target environment
4. Deploy to SSIS Catalog (SSISDB)
5. Schedule packages using SQL Server Agent

### **5. SSAS Cube Deployment**

1. Open SSAS project: `Code/SSAS/DWProject/`
2. Update data source connections
3. Deploy Analysis Services database
4. Process cube dimensions and measure groups
5. Configure security roles and access permissions
