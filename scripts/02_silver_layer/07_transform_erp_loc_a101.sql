/* ============================================================
   FILE: transform_erp_loc_a101.sql
   LAYER: Bronze -> Silver
   TABLE: erp_loc_a101

   PURPOSE:
   This script documents the transformation and standardization
   process applied to location/customer country data from
   bronze.erp_loc_a101 before loading it into silver.erp_loc_a101.

   OBJECTIVES:
   - Review source data structure
   - Validate the customer identifier used for joins
   - Standardize the customer ID format
   - Clean and normalize country values
   - Load clean data into the silver layer
   - Perform post-load validation checks

   NOTES:
   - Source data remains unchanged in the bronze layer
   - Transformations are applied during the load into silver
   ============================================================ */



/* ============================================================
   1. INITIAL SOURCE REVIEW
   Purpose:
   Review the main fields from the source table that will be used
   in the transformation process.
   ============================================================ */
SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101;



/* ============================================================
   2. FULL SOURCE TABLE CHECK
   Purpose:
   Inspect the entire source table to better understand the raw
   data before applying any transformations.
   ============================================================ */
SELECT *
FROM bronze.erp_loc_a101;



/* ============================================================
   3. REVIEW JOIN KEY FROM CUSTOMER MASTER TABLE
   Purpose:
   Check the key format used in silver.crm_cust_info in order to
   align cid from the source table with the customer master data.
   ============================================================ */
SELECT
    cst_key
FROM silver.crm_cust_info;



/* ============================================================
   4. STANDARDIZE CUSTOMER IDENTIFIER (cid)
   Purpose:
   Adjust the cid format so it can be matched with cst_key from
   silver.crm_cust_info.

   Current transformation:
   - Replace '-' with a blank space

   Important:
   This transformation should be validated against the expected
   cst_key format to confirm that replacing with a space is the
   intended business rule.
   ============================================================ */
SELECT
    cid AS original_cid,
    REPLACE(cid, '-', ' ') AS cleaned_cid,
    cntry
FROM bronze.erp_loc_a101;



/* ============================================================
   5. REVIEW COUNTRY VALUES
   Purpose:
   Inspect all distinct country values before standardization in
   order to identify abbreviations, nulls, blanks, and other
   inconsistent formats.
   ============================================================ */
SELECT DISTINCT
    cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;



/* ============================================================
   6. STANDARDIZE COUNTRY VALUES
   Purpose:
   Clean and normalize cntry values using the following rules:

   Rules:
   - Remove leading/trailing spaces
   - Remove tabs and line breaks
   - Convert blank values to 'n/a'
   - Map 'DE' to 'Germany'
   - Map 'US' and 'USA' to 'United States'
   - Preserve other cleaned values as they are

   Why this matters:
   - Improves reporting consistency
   - Prevents duplicate semantic values
   - Standardizes country naming conventions
   ============================================================ */
SELECT
    REPLACE(cid, '-', ' ') AS cid,
    cntry AS old_cntry,
    CASE
        WHEN NULLIF(
            LTRIM(RTRIM(
                REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
            )),
            ''
        ) IS NULL THEN 'n/a'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) = 'DE' THEN 'Germany'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('US', 'USA') THEN 'United States'

        ELSE LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))
    END AS cntry
FROM bronze.erp_loc_a101;



/* ============================================================
   7. LOAD CLEAN DATA INTO SILVER
   Purpose:
   Insert the cleaned and standardized dataset into
   silver.erp_loc_a101.
   ============================================================ */
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', ' ') AS cid,
    CASE
        WHEN NULLIF(
            LTRIM(RTRIM(
                REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
            )),
            ''
        ) IS NULL THEN 'n/a'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) = 'DE' THEN 'Germany'

        WHEN UPPER(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))) IN ('US', 'USA') THEN 'United States'

        ELSE LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(CAST(cntry AS VARCHAR(50)), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')
        ))
    END AS cntry
FROM bronze.erp_loc_a101;



/* ========================================================================================================================
   8. POST-LOAD VALIDATION: COUNTRY VALUES
   Purpose:
   Confirm that country values were standardized correctly after
   loading into the silver layer.
   ======================================================================================================================== */
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;



/* ============================================================
   9. FINAL TABLE REVIEW
   Purpose:
   Inspect the final state of the silver table after the load.
   ============================================================ */
SELECT *
FROM silver.erp_loc_a101;



/* ============================================================
   10. SOURCE TABLE REFERENCE
   Purpose:
   Keep the original bronze table available for comparison with
   the transformed silver output.
   ============================================================ */
SELECT *
FROM bronze.erp_loc_a101;
