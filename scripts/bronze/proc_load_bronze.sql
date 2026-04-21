/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - It truncates existing tables and reloads them from CSV files (full load).
    - It also logs execution steps, row counts, durations, and errors.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/ 

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

    -- Prevent extra messages like "(X rows affected)" to keep output clean
    SET NOCOUNT ON;

    -- Declare variables for tracking execution timing, row counts, and errors
    DECLARE 
        @start_time DATETIME,        -- start time for each table load
        @end_time DATETIME,          -- end time for each table load
        @batch_start_time DATETIME,  -- start time for the entire process
        @batch_end_time DATETIME,    -- end time for the entire process
        @row_count INT,              -- number of rows loaded into each table
        @duration INT,               -- duration in seconds for each operation
        @error_message NVARCHAR(4000), -- stores error message text
        @error_number INT,           -- stores SQL Server error number
        @error_state INT;            -- stores SQL Server error state

    BEGIN TRY

        -- Capture the start time of the entire load process
        SET @batch_start_time = GETDATE();

        -- Print process header (real-time output)
        RAISERROR('================================================', 0, 1) WITH NOWAIT;
        RAISERROR('Starting Bronze Layer Load', 0, 1) WITH NOWAIT;
        RAISERROR('================================================', 0, 1) WITH NOWAIT;

        --------------------------------------------------
        -- CRM TABLES
        --------------------------------------------------

        -- Inform that CRM tables loading is starting
        RAISERROR('Loading CRM Tables...', 0, 1) WITH NOWAIT;

        -- ==============================
        -- crm_cust_info
        -- ==============================

        -- Capture start time for this table
        SET @start_time = GETDATE();

        -- Remove all existing data from the table (full refresh)
        RAISERROR('>> Truncating: bronze.crm_cust_info', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_cust_info;

        -- Load data from CSV file into the table
        RAISERROR('>> Loading: bronze.crm_cust_info', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,              -- skip header row
            FIELDTERMINATOR = ',',     -- columns separated by commas
            ROWTERMINATOR = '0x0a',    -- define line break
            TABLOCK,                  -- improves performance
            CODEPAGE = '65001'         -- supports UTF-8 encoding
        );

        -- Count how many rows were loaded
        SELECT @row_count = COUNT(*) FROM bronze.crm_cust_info;

        -- Capture end time and calculate duration
        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        -- Print results
        RAISERROR('>> Rows Loaded: %d', 0, 1, @row_count) WITH NOWAIT;
        RAISERROR('>> Duration: %d sec', 0, 1, @duration) WITH NOWAIT;


        -- ==============================
        -- crm_prd_info
        -- ==============================

        SET @start_time = GETDATE();

        RAISERROR('>> Truncating: bronze.crm_prd_info', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_prd_info;

        RAISERROR('>> Loading: bronze.crm_prd_info', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        RAISERROR('>> Rows Loaded: %d', 0, 1, @row_count) WITH NOWAIT;
        RAISERROR('>> Duration: %d sec', 0, 1, @duration) WITH NOWAIT;


        -- ==============================
        -- crm_sales_details
        -- ==============================

        SET @start_time = GETDATE();

        RAISERROR('>> Truncating: bronze.crm_sales_details', 0, 1) WITH NOWAIT;
        TRUNCATE TABLE bronze.crm_sales_details;

        RAISERROR('>> Loading: bronze.crm_sales_details', 0, 1) WITH NOWAIT;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        RAISERROR('>> Rows Loaded: %d', 0, 1, @row_count) WITH NOWAIT;
        RAISERROR('>> Duration: %d sec', 0, 1, @duration) WITH NOWAIT;


        --------------------------------------------------
        -- ERP TABLES
        --------------------------------------------------

        RAISERROR('Loading ERP Tables...', 0, 1) WITH NOWAIT;

        -- ==============================
        -- erp_loc_a101
        -- ==============================

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SELECT @row_count = COUNT(*) FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        RAISERROR('>> erp_loc_a101 Rows: %d | Duration: %d sec', 0, 1, @row_count, @duration) WITH NOWAIT;


        -- ==============================
        -- erp_cust_az12
        -- ==============================

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SELECT @row_count = COUNT(*) FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        RAISERROR('>> erp_cust_az12 Rows: %d | Duration: %d sec', 0, 1, @row_count, @duration) WITH NOWAIT;


        -- ==============================
        -- erp_px_cat_g1v2
        -- ==============================

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        SELECT @row_count = COUNT(*) FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);

        RAISERROR('>> erp_px_cat_g1v2 Rows: %d | Duration: %d sec', 0, 1, @row_count, @duration) WITH NOWAIT;


        --------------------------------------------------
        -- FINAL SUMMARY
        --------------------------------------------------

        -- Capture end time of the full process
        SET @batch_end_time = GETDATE();

        -- Calculate total duration
        SET @duration = DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        -- Print final summary
        RAISERROR('================================================', 0, 1) WITH NOWAIT;
        RAISERROR('Bronze Load Completed Successfully', 0, 1) WITH NOWAIT;
        RAISERROR('Total Duration: %d sec', 0, 1, @duration) WITH NOWAIT;
        RAISERROR('================================================', 0, 1) WITH NOWAIT;

    END TRY

    BEGIN CATCH

        -- Capture error details
        SET @error_message = ERROR_MESSAGE();
        SET @error_number = ERROR_NUMBER();
        SET @error_state = ERROR_STATE();

        -- Print error information
        RAISERROR('================================================', 16, 1);
        RAISERROR('ERROR DURING BRONZE LOAD', 16, 1);
        RAISERROR(@error_message, 16, 1);
        RAISERROR('Error Number: %d', 16, 1, @error_number);
        RAISERROR('Error State: %d', 16, 1, @error_state);
        RAISERROR('================================================', 16, 1);

    END CATCH
END;
