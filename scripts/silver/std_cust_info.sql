/* ============================================================
   CUSTOMER INFORMATION TRANSFORMATION
   Source : bronze.crm_cust_info
   Target : silver.crm_cust_info

   Purpose:
   - Review source data quality
   - Identify nulls and duplicate customer IDs
   - Standardize text fields
   - Keep only the most recent record per customer
   - Load cleaned data into the silver layer
   ============================================================ */


/* ============================================================
   1. INITIAL DATA REVIEW
   Purpose: Inspect the raw source data before applying any
            validation or transformation logic.
   ============================================================ */
SELECT
    *
FROM bronze.crm_cust_info;


/* ============================================================
   2. PRIMARY KEY VALIDATION
   Purpose: Detect invalid customer IDs:
            - NULL customer IDs
            - Duplicate customer IDs

   Expectation:
   - No NULL values in cst_id
   - No duplicate values in cst_id
   ============================================================ */
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/* ============================================================
   3. DUPLICATE ANALYSIS
   Purpose: Identify duplicate records and rank them by recency.
            The most recent record per customer will be kept.

   Note:
   - rn = 1 represents the latest record for each cst_id
   - This query is useful for review before deletion or loading
   ============================================================ */
WITH ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)
SELECT
    *
FROM ranked_customers
WHERE rn > 1;


/* ============================================================
   4. SAMPLE DUPLICATE REVIEW
   Purpose: Inspect a specific duplicated customer ID to
            understand why duplicates exist.
   ============================================================ */
SELECT
    *
FROM bronze.crm_cust_info
WHERE cst_id = 29449;


/* ============================================================
   5. WHITESPACE VALIDATION
   Purpose: Detect leading or trailing spaces in text columns.
            Run these checks column by column as needed.
   ============================================================ */
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);


/* ============================================================
   6. DOMAIN VALUE REVIEW
   Purpose: Review distinct values before standardizing fields
            such as gender and marital status.
   ============================================================ */
SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info;


/* ============================================================
   7. FINAL LOAD TO SILVER LAYER
   Purpose:
   - Remove invalid records (NULL customer IDs)
   - Keep only the latest record per customer
   - Trim text fields
   - Standardize categorical values
   - Load clean data into silver.crm_cust_info
   ============================================================ */

/* Optional:
   Use this only when performing a full reload of the target table.
   Be careful: this removes all existing records from the target.
*/
-- TRUNCATE TABLE silver.crm_cust_info;


WITH source_ranked AS (
    /* --------------------------------------------------------
       Step 1: Rank source records by customer ID and recency
       -------------------------------------------------------- */
    SELECT
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
),

clean_customers AS (
    /* --------------------------------------------------------
       Step 2: Keep only the latest record and standardize data
       -------------------------------------------------------- */
    SELECT
        cst_id,
        cst_key,

        /* Remove extra spaces from text fields */
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,

        /* Standardize marital status values */
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,

        /* Standardize gender values */
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date
    FROM source_ranked
    WHERE rn = 1
)

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM clean_customers;
