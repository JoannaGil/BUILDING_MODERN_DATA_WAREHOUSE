/* ============================================================
   FILE: transform_erp_cust_az12.sql
   LAYER: Bronze -> Silver
   TABLE: erp_cust_az12

   PURPOSE:
   This script documents the transformation and cleansing process
   applied to customer data from bronze.erp_cust_az12 before loading
   it into the silver layer.

   OBJECTIVES:
   - Validate and clean customer identifiers (cid)
   - Standardize date values (bdate)
   - Clean and normalize gender values (gen)
   - Ensure data consistency for downstream integration
   - Load clean data into silver.erp_cust_az12

   NOTES:
   - Source data is preserved in the bronze layer
   - All transformations are applied before loading into silver
   ============================================================ */



/* ============================================================
   1. INITIAL SOURCE REVIEW
   Purpose:
   Inspect the raw source data and understand column structure.
   ============================================================ */
SELECT *
FROM bronze.erp_cust_az12;



/* ============================================================
   2. DATA COMPARISON WITH CUSTOMER TABLE
   Purpose:
   Validate if customer identifiers (cid) align with the existing
   customer master table (silver.crm_cust_info).
   ============================================================ */
SELECT 
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;

SELECT *
FROM silver.crm_cust_info;

/*
   Observation:
   Some cid values do not match cst_key format.
*/



/* ============================================================
   3. CLEAN CUSTOMER IDENTIFIER (cid)
   Purpose:
   Remove prefix 'NAS' from customer IDs when present.

   Example:
   NAS12345 → 12345
   ============================================================ */
SELECT 
    cid AS original_cid,
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cleaned_cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;



/* ============================================================
   4. VALIDATE DATE OF BIRTHDAY (bdate)
   Purpose:
   Identify invalid or unrealistic date values.

   Rules:
   - No future dates allowed
   - No extremely old dates (before 1924-01-01)
   ============================================================ */
SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();



/* ============================================================
   5. CLEAN DATE VALUES
   Purpose:
   Replace invalid future dates with NULL.
   ============================================================ */
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,

    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    gen
FROM bronze.erp_cust_az12;



/* ============================================================
   6. REVIEW GENDER VALUES
   Purpose:
   Identify all distinct values in the gender column before
   applying standardization.
   ============================================================ */
SELECT DISTINCT
    gen
FROM bronze.erp_cust_az12;



/* ============================================================
   7. CLEAN AND STANDARDIZE GENDER VALUES
   Purpose:
   Normalize gender values and handle invalid or inconsistent data.

   Transformations:
   - Remove spaces, tabs, and hidden characters
   - Convert values to uppercase
   - Map values to standard labels:
        F / FEMALE → Female
        M / MALE   → Male
   - Replace NULL or empty values with 'n/a'
   ============================================================ */
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,

    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN NULLIF(
            LTRIM(RTRIM(
                REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
            )),
            ''
        ) IS NULL THEN 'n/a'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('F', 'FEMALE') THEN 'Female'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('M', 'MALE') THEN 'Male'

        ELSE 'n/a'
    END AS gen_clean

FROM bronze.erp_cust_az12;



/* ============================================================
   8. LOAD CLEAN DATA INTO SILVER LAYER
   Purpose:
   Insert cleaned and standardized records into
   silver.erp_cust_az12.
   ============================================================ */
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,

    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN NULLIF(
            LTRIM(RTRIM(
                REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
            )),
            ''
        ) IS NULL THEN 'n/a'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('F', 'FEMALE') THEN 'Female'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(gen AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('M', 'MALE') THEN 'Male'

        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;



/* ========================================================================================================================
   9. POST-LOAD VALIDATION
   ======================================================================================================================== */

-- Validate date ranges
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- Validate standardized gender values
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- Final table review
SELECT *
FROM silver.erp_cust_az12;
