/* ============================================================
   FILE: transform_erp_px_cat_g1v2.sql
   LAYER: Bronze -> Silver
   TABLE: erp_px_cat_g1v2

   PURPOSE:
   This script documents the review and load process for the
   product category reference table bronze.erp_px_cat_g1v2 into
   silver.erp_px_cat_g1v2.

   OBJECTIVES:
   - Review source data structure
   - Validate the join key used with product data
   - Check for unwanted spaces in text fields
   - Review data consistency and distinct values
   - Confirm whether transformations are needed
   - Load validated data into the silver layer

   NOTES:
   - No structural or content changes were required
   - Source data was considered clean and consistent
   - Data was loaded into silver without transformation
   ============================================================ */



/* ============================================================
   1. INITIAL SOURCE REVIEW
   Purpose:
   Review the main fields from the source table to understand
   the structure and contents of the category reference data.
   ============================================================ */
SELECT
    id,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;



/* ============================================================
   2. VALIDATE JOIN KEY AGAINST PRODUCT TABLE
   Purpose:
   Confirm that the category identifier (id) from the source
   table matches the category key format used in
   silver.crm_prd_info.

   Observation:
   No changes were required for id. The source format already
   matches the target join format.
   ============================================================ */
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT
    cat_id
FROM silver.crm_prd_info;



/* ============================================================
   3. CHECK FOR UNWANTED SPACES
   Purpose:
   Identify leading or trailing spaces in text columns that
   could affect joins, filtering, grouping, or reporting.

   Columns reviewed:
   - cat
   - subcat
   - maintenance
   ============================================================ */
SELECT
    *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

/*
   Expected result:
   No rows returned.
*/



/* ============================================================
   4. DATA STANDARDIZATION AND CONSISTENCY REVIEW
   Purpose:
   Review distinct values in the main descriptive columns to
   confirm consistency and identify whether any normalization
   or mapping rules are required.
   ============================================================ */
SELECT DISTINCT
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

/*
   Observation:
   No standardization changes were required.
   All reviewed values were considered consistent and in good
   data quality condition.
*/



/* ============================================================
   5. LOAD DATA INTO SILVER
   Purpose:
   Load the validated reference data into silver.erp_px_cat_g1v2.

   Note:
   Since no transformations were required, the data is loaded
   as-is from the bronze layer.
   ============================================================ */
TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;



/* ========================================================================================================================
   6. POST-LOAD VALIDATION
   Purpose:
   Confirm that the data was loaded correctly into the silver
   layer and remains consistent with the source.
   ======================================================================================================================== */
SELECT
    *
FROM silver.erp_px_cat_g1v2;



/* ============================================================
   7. SOURCE TABLE REFERENCE
   Purpose:
   Keep the original bronze table available for comparison with
   the loaded silver output.
   ============================================================ */
SELECT
    *
FROM bronze.erp_px_cat_g1v2;
