/* ============================================================
   FILE: transform_crm_sales_details.sql
   LAYER: Bronze -> Silver
   TABLE: crm_sales_details

   PURPOSE:
   This script documents the step-by-step transformation process
   applied to bronze.crm_sales_details before loading the data
   into silver.crm_sales_details.

   OBJECTIVES:
   - Review raw sales data
   - Validate join keys against reference tables
   - Standardize and convert integer-based date fields
   - Apply business rules to sales, quantity, and price
   - Load clean and validated data into the silver layer
   - Perform post-load quality checks

   NOTES:
   - Source data is preserved in the bronze layer
   - All cleansing and business-rule adjustments are applied
     during transformation before loading into silver
   ============================================================ */



/* ============================================================
   1. INITIAL SOURCE REVIEW
   Purpose:
   Inspect the source table and review the main columns that
   will be transformed and loaded into the silver layer.
   ============================================================ */
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;



/* ============================================================
   2. CHECK FOR UNWANTED SPACES IN ORDER NUMBER
   Purpose:
   Validate that sls_ord_num does not contain leading or trailing
   spaces that could affect joins, filtering, or reporting.
   ============================================================ */
SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num);



/* ============================================================
   3. VALIDATE PRODUCT KEY AGAINST REFERENCE TABLE
   Purpose:
   Confirm that all product keys in sales exist in the cleaned
   product reference table silver.crm_prd_info.
   ============================================================ */
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM silver.crm_prd_info
);

/*
   Expected result:
   No rows returned.
*/



/* ============================================================
   4. VALIDATE CUSTOMER ID AGAINST REFERENCE TABLE
   Purpose:
   Confirm that all customer IDs in sales exist in the cleaned
   customer reference table silver.crm_cust_info.
   ============================================================ */
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM silver.crm_cust_info
);

/*
   Expected result:
   No rows returned.
*/



/* ============================================================
   5. DATE CONVERSION STRATEGY
   Purpose:
   The following columns are stored as integers in the source
   and must be converted to DATE in the silver layer:
   - sls_order_dt
   - sls_ship_dt
   - sls_due_dt

   Validation rules:
   - Zero values are treated as invalid and converted to NULL
   - Values with length different from 8 are treated as invalid
   - Valid values are cast from INT -> VARCHAR -> DATE
   ============================================================ */



/* ============================================================
   6. VALIDATE ORDER DATE
   ============================================================ */
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) <> 8;



/* ============================================================
   7. VALIDATE SHIP DATE
   ============================================================ */
SELECT
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) <> 8;



/* ============================================================
   8. VALIDATE DUE DATE
   ============================================================ */
SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) <> 8;



/* ============================================================
   9. PREVIEW DATE STANDARDIZATION
   Purpose:
   Apply the conversion rules to preview how the date fields
   will look after transformation.
   ============================================================ */
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;



/* ============================================================
   10. VALIDATE DATE ORDER LOGIC
   Purpose:
   Ensure the business timeline is valid:
   - Order date must not be later than ship date
   - Order date must not be later than due date
   ============================================================ */
SELECT
    *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

/*
   Expected result:
   No rows returned.
*/



/* ============================================================
   11. REVIEW SALES BUSINESS RULES
   Business rules:
   - sls_sales = sls_quantity * sls_price
   - sls_sales, sls_quantity, and sls_price should be positive
   - No NULL, zero, or negative values should remain unless
     explicitly handled by transformation logic
   ============================================================ */
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;



/* ============================================================
   12. BUSINESS RULES TO FIX INVALID SALES VALUES
   Rules applied:
   - If sales is NULL, zero, negative, or inconsistent, derive it
     as quantity * ABS(price)
   - If price is NULL or zero/negative, derive it as
     sales / quantity
   - If price is negative, convert it to a positive reference
     using ABS(price) when recalculating sales
   ============================================================ */
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,

    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;



/* ============================================================
   13. FINAL TRANSFORMATION PREVIEW
   Purpose:
   Preview the full cleaned dataset before loading into silver.
   ============================================================ */
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;



/* ============================================================
   14. LOAD CLEAN DATA INTO SILVER
   Purpose:
   Replace the current silver data with the transformed output.
   ============================================================ */
TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;



/* ============================================================
   15. POST-LOAD VALIDATION: INVALID DATE ORDER
   Purpose:
   Confirm that date relationships remain valid after loading.
   ============================================================ */
SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;



/* ============================================================
   16. POST-LOAD VALIDATION: SALES RULES
   Purpose:
   Confirm that sales, quantity, and price follow the expected
   business rules in the silver layer.
   ============================================================ */
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;



/* ============================================================
   17. FINAL TABLE REVIEW
   Purpose:
   Inspect the final state of the silver table after all
   transformations and validations.
   ============================================================ */
SELECT
    *
FROM silver.crm_sales_details;
