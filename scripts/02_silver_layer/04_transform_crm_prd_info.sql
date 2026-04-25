/* ============================================================
   FILE: transform_crm_prd_info.sql
   LAYER: Bronze -> Silver
   TABLE: crm_prd_info

   PURPOSE:
   This script documents the step-by-step transformation process
   for product information data coming from bronze.crm_prd_info.

   The process includes:
   1. Initial source inspection
   2. Primary key validation
   3. Product key decomposition
   4. Data standardization for joins
   5. Data quality checks
   6. Categorical value standardization
   7. Date range correction
   8. Final load into silver.crm_prd_info
   9. Post-load validation

   NOTES:
   - The source table is preserved as raw input.
   - All cleaning and standardization logic is applied during
     transformation before loading into the silver layer.
   ============================================================ */



/* ============================================================
   1. INITIAL SOURCE REVIEW
   Purpose:
   Inspect the raw source data and review the main columns that
   will be used in the transformation process.
   ============================================================ */
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;



/* ============================================================
   2. PRIMARY KEY VALIDATION
   Purpose:
   Verify that the product identifier (prd_id) does not contain:
   - NULL values
   - Duplicate values

   Expectation:
   This query should return no rows.
   ============================================================ */
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
   OR prd_id IS NULL;



/* ============================================================
   3. SPLIT PRODUCT KEY - CATEGORY IDENTIFICATION
   Purpose:
   Extract the category portion from prd_key.
   The first 5 characters represent the category code.
   ============================================================ */
SELECT
    prd_id,
    SUBSTRING(prd_key, 1, 5) AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   4. CHECK CATEGORY KEY FORMAT AGAINST REFERENCE TABLE
   Purpose:
   Review the category IDs available in the ERP category table
   in order to confirm the required format for future joins.
   ============================================================ */
SELECT DISTINCT
    id
FROM bronze.erp_px_cat_g1v2;


/* ============================================================
   5. STANDARDIZE CATEGORY KEY FORMAT
   Purpose:
   Replace '-' with '_' in the category portion of prd_key so
   the format matches the category reference table.

   Example:
   Original: AC-HE
   Standard: AC_HE
   ============================================================ */
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   6. CHECK PRODUCT KEY FORMAT AGAINST SALES TABLE
   Purpose:
   Review the product key format used in crm_sales_details to
   confirm how prd_key should be standardized for joins.
   ============================================================ */
SELECT DISTINCT
    sls_prd_key
FROM bronze.crm_sales_details;


/* ============================================================
   7. SPLIT AND STANDARDIZE PRODUCT KEY
   Purpose:
   Transform prd_key into two separate business attributes:
   - cat_id  : first 5 characters, standardized with '_'
   - prd_key : remaining portion after position 6

   This prepares the data for joins with both:
   - bronze.erp_px_cat_g1v2
   - bronze.crm_sales_details
   ============================================================ */
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   8. PRODUCT NAME QUALITY CHECK
   Purpose:
   Detect leading or trailing spaces in product names.
   ============================================================ */
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

/*
   Result:
   No unwanted spaces were found in prd_nm.
*/

/* ============================================================
   9. PRODUCT COST QUALITY CHECK
   Purpose:
   Detect invalid cost values:
   - NULL values
   - Negative values

   Business rule:
   NULL costs were approved by the business to be replaced with 0.
   ============================================================ */
SELECT
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


/* ============================================================
   10. REPLACE NULL COSTS
   Purpose:
   Standardize prd_cost by replacing NULL values with 0 based on
   business approval.
   ============================================================ */
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   11. PRODUCT LINE STANDARDIZATION REVIEW
   Purpose:
   Review the distinct values in prd_line before standardizing
   the abbreviations into full descriptive values.
   ============================================================ */
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;


/* ============================================================
   12. STANDARDIZE PRODUCT LINE VALUES
   Purpose:
   Convert abbreviated values in prd_line into descriptive labels.

   Mapping:
   M -> Mountain
   R -> Road
   S -> Other Sales
   T -> Touring
   Any other value -> n/a
   ============================================================ */
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   13. DATE VALIDATION
   Purpose:
   Identify invalid date ranges where prd_end_dt occurs before
   prd_start_dt.
   ============================================================ */
SELECT
    *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/* ============================================================
   14. TEST DATE RANGE CORRECTION
   Purpose:
   Validate the logic used to correct overlapping or inconsistent
   product date ranges.

   Logic:
   prd_end_dt_test is calculated as one day before the next
   prd_start_dt for the same prd_key.

   This test is performed on sample product keys before applying
   the logic to the full dataset.
   ============================================================ */
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    DATEADD(
        DAY,
        -1,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        )
    ) AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509R', 'AC-HE-HL-U509');


/* ============================================================
   15. FINAL TRANSFORMATION PREVIEW
   Purpose:
   Preview the fully transformed dataset before loading it into
   the silver layer.

   Transformations applied:
   - cat_id extracted and standardized
   - prd_key shortened for downstream use
   - NULL prd_cost replaced with 0
   - prd_line standardized
   - prd_start_dt cast as DATE
   - prd_end_dt recalculated using LEAD()
   ============================================================ */
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    DATEADD(
        DAY,
        -1,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        )
    ) AS prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   16. FINAL LOAD INTO SILVER
   Purpose:
   Insert the cleaned and standardized product data into
   silver.crm_prd_info.
   ============================================================ */
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    DATEADD(
        DAY,
        -1,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        )
    ) AS prd_end_dt
FROM bronze.crm_prd_info;


/* ============================================================
   17. POST-LOAD VALIDATION
   Purpose:
   Confirm that the data was loaded into silver.crm_prd_info.
   ============================================================ */
SELECT
    *
FROM silver.crm_prd_info;

/* ================================================================================================================================
   18. POST-LOAD DATA QUALITY CHECKS
   ================================================================================================================================ */
-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
