/* ============================================================
   FILE: create_gold_dim_products.sql
   LAYER: Gold
   OBJECT: gold.dim_products

   PURPOSE:
   Create the product dimension in the Gold layer by integrating
   product information with product category details.

   SOURCE TABLES:
   - silver.crm_prd_info
   - silver.erp_px_cat_g1v2

   OBJECTIVES:
   - Review product data from the Silver layer
   - Filter only current product records
   - Join product information with category reference data
   - Validate product key uniqueness
   - Standardize column names for business consumption
   - Create a surrogate key for the dimensional model
   - Create the final Gold layer product dimension view
   ============================================================ */



/* ============================================================
   1. INITIAL PRODUCT DATA REVIEW
   Purpose:
   Inspect the product information available in the Silver layer
   before applying filters, joins, or final naming standards.
   ============================================================ */
SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pn.prd_end_dt
FROM silver.crm_prd_info AS pn;



/* ============================================================
   2. FILTER CURRENT PRODUCT RECORDS
   Purpose:
   Identify the current active version of each product.

   Business rule:
   - If prd_end_dt IS NULL, the record represents the current
     product information.
   - Historical product records are excluded from the dimension.
   ============================================================ */
SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt
FROM silver.crm_prd_info AS pn
WHERE pn.prd_end_dt IS NULL;



/* ============================================================
   3. JOIN PRODUCT DATA WITH CATEGORY DATA
   Purpose:
   Enrich product records with category, subcategory, and
   maintenance information.

   LEFT JOIN is used to preserve all current product records,
   even if a matching category is missing in the ERP category
   reference table.
   ============================================================ */
SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc 
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;



/* ============================================================
   4. CHECK PRODUCT KEY UNIQUENESS
   Purpose:
   Validate that the current product dataset contains only one
   active record per product key.

   Expectation:
   This query should return no rows.
   ============================================================ */
SELECT 
    prd_key,
    COUNT(*) AS record_count
FROM (
    SELECT
        pn.prd_key
    FROM silver.crm_prd_info AS pn
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc 
        ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL
) AS f
GROUP BY prd_key
HAVING COUNT(*) > 1;

/*
   Result:
   No duplicate current product keys should be found.
*/



/* ============================================================
   5. STANDARDIZE COLUMN NAMES AND ORGANIZE OUTPUT
   Purpose:
   Rename technical Silver layer column names into clear,
   business-friendly names for the Gold layer.

   Examples:
   - prd_id       -> product_id
   - prd_key      -> product_number
   - prd_nm       -> product_name
   - cat_id       -> category_id
   - prd_cost     -> cost
   - prd_line     -> product_line
   - prd_start_dt -> start_date
   ============================================================ */
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc 
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;



/* ============================================================
   6. CREATE GOLD PRODUCT DIMENSION VIEW
   Purpose:
   Create the final product dimension in the Gold layer.

   This dimension contains the current version of each product,
   enriched with category details and prepared for analytical
   reporting and fact table relationships.

   Note:
   product_key is created as a surrogate key using ROW_NUMBER().
   ============================================================ */
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc 
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
GO



/* ============================================================
   7. QUALITY CHECK: REVIEW FINAL PRODUCT DIMENSION
   Purpose:
   Inspect the final product dimension after view creation.
   ============================================================ */
SELECT *
FROM gold.dim_products;



/* ============================================================
   8. QUALITY CHECK: CHECK PRODUCT KEY UNIQUENESS
   Purpose:
   Confirm that product_number remains unique in the final Gold
   product dimension.
   ============================================================ */
SELECT
    product_number,
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;
