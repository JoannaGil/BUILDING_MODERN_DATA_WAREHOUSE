/* ============================================================
   FILE: create_gold_dim_customer.sql
   LAYER: Gold
   OBJECT: gold.dim_customer

   PURPOSE:
   Create the customer dimension in the Gold layer by integrating
   customer information from multiple Silver layer tables.

   SOURCE TABLES:
   - silver.crm_cust_info
   - silver.erp_cust_az12
   - silver.erp_loc_a101
   ============================================================ */


/* ============================================================
   1. JOIN CUSTOMER TABLES
   Purpose:
   Combine CRM customer data with ERP demographic and location
   information.

   LEFT JOIN is used to preserve all customer records from
   silver.crm_cust_info.
   ============================================================ */
SELECT 
    ci.cst_id, 
    ci.cst_key, 
    ci.cst_firstname, 
    ci.cst_lastname, 
    ci.cst_marital_status, 
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/* ============================================================
   2. CHECK FOR DUPLICATES AFTER JOIN
   Purpose:
   Confirm that the joins did not create duplicate customer
   records.

   Expectation:
   No rows should be returned.
   ============================================================ */
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM (
    SELECT 
        ci.cst_id, 
        ci.cst_key, 
        ci.cst_firstname, 
        ci.cst_lastname, 
        ci.cst_marital_status, 
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
        ON ci.cst_key = la.cid
) AS t
GROUP BY cst_id 
HAVING COUNT(*) > 1;

/*
   Result:
   No duplicates found.
*/


/* ============================================================
   3. REVIEW GENDER VALUES FROM BOTH SOURCES
   Purpose:
   Compare CRM gender and ERP gender before applying the final
   integration rule.
   ============================================================ */
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


/* ============================================================
   4. INTEGRATE GENDER DATA
   Purpose:
   Create one unified gender attribute.

   Business rule:
   - CRM is the master source for gender information.
   - If CRM gender is not 'n/a', use CRM gender.
   - Otherwise, use ERP gender.
   - If ERP gender is missing, default to 'n/a'.
   ============================================================ */
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/* ============================================================
   5. PREVIEW CUSTOMER DATA WITH INTEGRATED GENDER
   Purpose:
   Apply the gender integration rule and review the resulting
   customer dataset before renaming columns.
   ============================================================ */
SELECT 
    ci.cst_id, 
    ci.cst_key, 
    ci.cst_firstname, 
    ci.cst_lastname, 
    ci.cst_marital_status, 
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen,
    ci.cst_create_date,
    ca.bdate,
    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/* ============================================================
   6. STANDARDIZE COLUMN NAMES
   Purpose:
   Rename technical Silver layer columns into clear business
   names for the Gold layer.
   ============================================================ */
SELECT 
    ci.cst_id AS customer_id, 
    ci.cst_key AS customer_number, 
    ci.cst_firstname AS first_name, 
    ci.cst_lastname AS last_name, 
    la.cntry AS country,
    ci.cst_marital_status AS marital_status, 
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date	
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/* ============================================================
   7. CREATE SURROGATE KEY
   Purpose:
   Generate customer_key as the surrogate key for the customer
   dimension.

   This key will be used to connect the dimensional model with
   related fact tables.
   ============================================================ */
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id, 
    ci.cst_key AS customer_number, 
    ci.cst_firstname AS first_name, 
    ci.cst_lastname AS last_name, 
    la.cntry AS country,
    ci.cst_marital_status AS marital_status, 
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date	
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/* ============================================================
   8. CREATE GOLD CUSTOMER DIMENSION VIEW
   Purpose:
   Create the final customer dimension in the Gold layer.
   ============================================================ */
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO
  
CREATE VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id, 
    ci.cst_key AS customer_number, 
    ci.cst_firstname AS first_name, 
    ci.cst_lastname AS last_name, 
    la.cntry AS country,
    ci.cst_marital_status AS marital_status, 
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date	
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;
GO


/* ============================================================
   9. QUALITY CHECK: REVIEW FINAL DIMENSION
   Purpose:
   Inspect the final customer dimension after creation.
   ============================================================ */
SELECT *
FROM gold.dim_customer;


/* ============================================================
   10. QUALITY CHECK: REVIEW GENDER VALUES
   Purpose:
   Confirm that gender values were integrated correctly.
   ============================================================ */
SELECT DISTINCT 
    gender 
FROM gold.dim_customer;



