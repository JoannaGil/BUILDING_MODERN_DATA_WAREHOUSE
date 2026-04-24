/* ============================================================
   FILE: create_gold_fact_sales.sql
   LAYER: Gold
   OBJECT: gold.fact_sales

   PURPOSE:
   Create the sales fact view in the Gold layer by connecting
   cleaned sales transactions with the customer and product
   dimensions.

   SOURCE TABLES / VIEWS:
   - silver.crm_sales_details
   - gold.dim_products
   - gold.dim_customer

   OBJECTIVES:
   - Review sales transaction data from the Silver layer
   - Join sales data with product and customer dimensions
   - Replace source IDs with dimension surrogate keys
   - Rename columns using business-friendly names
   - Create the final Gold layer sales fact view
   - Validate foreign key integrity with dimensions
   ============================================================ */



/* ============================================================
   1. INITIAL SALES DATA REVIEW
   Purpose:
   Inspect the sales data available in the Silver layer before
   joining it with dimensions.
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
FROM silver.crm_sales_details;



/* ============================================================
   2. JOIN SALES DATA WITH DIMENSIONS
   Purpose:
   Build the base fact dataset by joining sales transactions with
   product and customer dimensions.

   LEFT JOIN is used to preserve all sales transactions, even if
   a matching dimension record is missing.

   Dimensional modeling rule:
   Facts should use dimension surrogate keys instead of source
   system IDs whenever possible.
   ============================================================ */
SELECT
    sd.sls_ord_num,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales,
    sd.sls_quantity,
    sd.sls_price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer AS cu
    ON sd.sls_cust_id = cu.customer_id;



/* ============================================================
   3. STANDARDIZE COLUMN NAMES AND ORGANIZE OUTPUT
   Purpose:
   Rename technical Silver layer fields into business-friendly
   names for the Gold fact view.

   Examples:
   - sls_ord_num  -> order_number
   - sls_order_dt -> order_date
   - sls_ship_dt  -> shipping_date
   - sls_due_dt   -> due_date
   - sls_sales    -> sales_amount
   - sls_quantity -> quantity
   - sls_price    -> price
   ============================================================ */
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer AS cu
    ON sd.sls_cust_id = cu.customer_id;



/* ============================================================
   4. CREATE GOLD SALES FACT VIEW
   Purpose:
   Create the final sales fact view in the Gold layer.

   This fact view stores measurable business events and connects
   to dimensions using surrogate keys:
   - product_key
   - customer_key
   ============================================================ */
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer AS cu
    ON sd.sls_cust_id = cu.customer_id;
GO



/* ============================================================
   5. QUALITY CHECK: REVIEW FINAL FACT VIEW
   Purpose:
   Inspect the final sales fact view after creation.
   ============================================================ */
SELECT *
FROM gold.fact_sales;



/* ============================================================
   6. QUALITY CHECK: CUSTOMER FOREIGN KEY INTEGRITY
   Purpose:
   Validate that every customer_key in the fact view exists in
   gold.dim_customer.

   Expectation:
   This query should return no rows.
   ============================================================ */
SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;



/* ============================================================
   7. QUALITY CHECK: PRODUCT FOREIGN KEY INTEGRITY
   Purpose:
   Validate that every product_key in the fact view exists in
   gold.dim_products.

   Expectation:
   This query should return no rows.
   ============================================================ */
SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;
