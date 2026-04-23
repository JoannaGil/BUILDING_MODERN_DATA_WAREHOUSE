# Silver Layer 

<img width="1253" height="180" alt="Captura de pantalla 2026-04-21 a la(s) 7 51 33 p  m" src="https://github.com/user-attachments/assets/e991532b-f21b-499a-8acd-1e0578a628aa" />
<br>
<br>

## Analysing: Explore & Understand Data
<p align="justify"> A critical first step in the Silver layer is to explore and fully understand the source data. This includes identifying data structures, column meanings, data quality issues, and relationships between tables. <br><br> One effective way to organize this analysis is by creating a <b>data integration map</b>. This helps identify the key fields (business keys) that connect tables across systems and ensures consistency in downstream transformations. </p>
<br>

### Exploring the tables: 

<img width="332" height="95" alt="Captura de pantalla 2026-04-23 a la(s) 11 24 18 a  m" src="https://github.com/user-attachments/assets/00b02776-8c3d-4c16-b269-254cd6923447" />
<br>
<img width="471" height="56" alt="Captura de pantalla 2026-04-23 a la(s) 11 22 17 a  m" src="https://github.com/user-attachments/assets/5508e0ca-4c6c-4c79-bd98-4d1f5ea418bc" />

<br>
<p align="justify"> During this phase, each table is reviewed to: </p>

* Understand column definitions and data types<br>
* Identify primary keys and potential duplicates<br>
* Detect null values and data inconsistencies<br>
* Recognize relationships between datasets<br>
<br>

## Draw Data Integration (Draw.io)
<p align="justify"> After reviewing the tables, the <b>common keys and relationships</b> between datasets were identified. <br><br> These relationships were then visualized using a data integration diagram, which serves as a reference for how data flows and connects across different tables. </p>
<br>
<img width="1352" height="756" alt="Captura de pantalla 2026-04-21 a la(s) 8 04 32 p  m" src="https://github.com/user-attachments/assets/a8536140-8db3-40da-9b1e-e9274fc29733" />

## Types of Transformations Applied in crm_prd_info

### 1. Derived Columns 
<p align="justify"> New columns were created based on transformations or calculations from existing fields. This helps reshape the data into a more analytical and business-friendly format. </p>

**Use case:**
* Splitting composite keys (e.g., prd_key)<br>
* Creating category identifiers (cat_id)<br>
* Generating new attributes from existing ones<br>

**Example:** 
<br><br>
<img width="659" height="49" alt="Captura de pantalla 2026-04-22 a la(s) 1 35 16 p  m" src="https://github.com/user-attachments/assets/ac5106cc-9852-45c6-bbac-f29082d6b1cb" />

### 2. Handling Missing Information (ISNULL)

<p align="justify"> Missing or NULL values were standardized using business rules to ensure data consistency. <br><br> For example, numeric fields such as cost were defaulted to <b>0</b> when NULL values were detected, based on business approval. </p>

**Important:**

* This avoids issues in aggregations and reporting<br>
* Ensures consistent downstream calculations<br>

**Example:** 
<br><br>
<img width="396" height="35" alt="Captura de pantalla 2026-04-22 a la(s) 2 17 05 p  m" src="https://github.com/user-attachments/assets/c62bd241-44f7-47b0-9dc3-1e5a9da920b0" />

### 3. Data Normalization
<p align="justify"> Data normalization ensures consistency in format and structure across datasets.</p> 

**This includes:** 
* Removing extra spaces (TRIM)><br> 
* Standardizing text case (UPPER)><br> 
* Aligning key formats (e.g., replacing '-' with '_')><br>

**Why it matters:**

* Ensures successful joins between tables><br>
* Prevents duplicate mismatches><br>
* Improves data quality><br>

**Example:** 
<br><br>
<img width="376" height="180" alt="Captura de pantalla 2026-04-22 a la(s) 2 18 53 p  m" src="https://github.com/user-attachments/assets/aa2a4143-8b0a-4e16-9dd7-3fa12d5ddf55" />

### 4. Data Type Casting

<p align="justify"> Data types were converted to ensure consistency and compatibility across transformations and reporting layers. <br><br> For example, datetime values were cast to DATE format to standardize date handling. </p>

**Why it matters:**

* Prevents type conflicts
* Improves query performance
* Ensures consistent filtering and grouping

**Example:** 
<br><br>
<img width="535" height="28" alt="Captura de pantalla 2026-04-22 a la(s) 2 22 14 p  m" src="https://github.com/user-attachments/assets/9cb59074-a912-43a1-837f-6f24aabe5250" />

### 5. Data Enrichment

<p align="justify"> Raw coded values were transformed into more descriptive, user-friendly values to improve readability and usability. </p>

**Examples:**

M → Mountain  <br>
R → Road        <br>
S → Other Sales   <br>
T → Touring         <br>

**Why it matters:**

* Improves business understanding
* Makes reports more intuitive
* Reduces dependency on lookup tables


**Example:** 
<br><br>
<img width="376" height="180" alt="Captura de pantalla 2026-04-22 a la(s) 2 18 53 p  m" src="https://github.com/user-attachments/assets/d4680fab-3c07-4045-9fbf-a29d5e7414d6" />



### 6. Temporal Data Transformation
<p align="justify"> Date ranges were corrected to avoid overlaps and ensure continuity in product history. <br><br> The end date (`prd_end_dt`) was recalculated as: </p>
One day before the next prd_start_dt for the same product
<p align="justify"> This was implemented using a window function (`LEAD()`), ensuring proper sequencing of product records over time. </p>

**Why it matters:**

* Prevents overlapping date ranges
* Supports historical tracking (SCD-like behavior)
* Improves accuracy in time-based analysis

**Example:** 
<br><br>
<img width="1059" height="30" alt="Captura de pantalla 2026-04-22 a la(s) 2 35 16 p  m" src="https://github.com/user-attachments/assets/26c02793-a056-427d-809c-55d15beaf00a" />

## Table Before and After Transformations

**Before** 
<img width="503" height="56" alt="Captura de pantalla 2026-04-22 a la(s) 2 40 55 p  m" src="https://github.com/user-attachments/assets/8419810d-f0ee-46c2-9ac1-f2b40af40330" />

<br>

**After** 
<img width="647" height="56" alt="Captura de pantalla 2026-04-22 a la(s) 2 39 46 p  m" src="https://github.com/user-attachments/assets/e83f560e-4716-474c-a0f7-076409db352a" />

<br><br>

## Types of Transformations Applied in crm_sales_details

### 1. Handling Invalid Data and Data Type Casting 

<img width="669" height="71" alt="Captura de pantalla 2026-04-22 a la(s) 6 51 49 p  m" src="https://github.com/user-attachments/assets/40cd6111-9a87-41d2-a9de-9175052f93f9" />

### 2. Handling Missing Data Using Default Value Imputation (ISNULL)

<img width="951" height="92" alt="Captura de pantalla 2026-04-22 a la(s) 6 55 12 p  m" src="https://github.com/user-attachments/assets/b070ba40-0557-4b51-a3a3-c61866e7aea7" />

## Table Before and After Transformations

**Before** 
<img width="534" height="58" alt="Captura de pantalla 2026-04-22 a la(s) 6 57 34 p  m" src="https://github.com/user-attachments/assets/b3325117-b29b-4704-a792-dc0884a42e1d" />

<br>

**After** 
<img width="667" height="59" alt="Captura de pantalla 2026-04-22 a la(s) 6 58 44 p  m" src="https://github.com/user-attachments/assets/1bb23fb3-0336-4a49-89ce-f8824d6a1ab9" />

<br><br>

## Types of Transformations Applied in erp_cust_az12

### 1. Handling and Correcting Invalid Data

<img width="666" height="140" alt="Captura de pantalla 2026-04-22 a la(s) 9 01 51 p  m" src="https://github.com/user-attachments/assets/f5341740-4bd9-46ca-8c5c-6e3cf6bbe992" />

### 2. Data Standardization

<img width="1028" height="164" alt="Captura de pantalla 2026-04-22 a la(s) 9 02 46 p  m" src="https://github.com/user-attachments/assets/622a8fef-5b69-4d91-b1eb-6fe030e8f510" />

## Table Before and After Transformations

**Before** 
<img width="211" height="56" alt="Captura de pantalla 2026-04-22 a la(s) 9 08 10 p  m" src="https://github.com/user-attachments/assets/3aabffe4-fff7-4e22-ba6f-825474f9f092" />

<br>

**After** 
<img width="320" height="58" alt="Captura de pantalla 2026-04-22 a la(s) 9 07 40 p  m" src="https://github.com/user-attachments/assets/d6ab1e7b-da24-4895-ad61-acbe10aa49a8" />

<br><br>

## Table Before and After Transformations - erp_loc_a101

**Before** 
<img width="151" height="58" alt="Captura de pantalla 2026-04-23 a la(s) 10 25 54 a  m" src="https://github.com/user-attachments/assets/9935de69-6c7b-4e58-aa70-ac5b0f9b9734" />

<br>

**After** 
<img width="292" height="58" alt="Captura de pantalla 2026-04-23 a la(s) 10 26 12 a  m" src="https://github.com/user-attachments/assets/0de7c08b-7c9d-488b-8bb4-61978b22a3a8" />
<br><br>

## Table Before and After Transformations - erp_px_cat_g1v1

**Before** 
<img width="306" height="60" alt="Captura de pantalla 2026-04-23 a la(s) 11 11 57 a  m" src="https://github.com/user-attachments/assets/d19a0af1-920a-4114-bfd6-05b9bd1468d5" />

<br>

**After** 
<img width="438" height="56" alt="Captura de pantalla 2026-04-23 a la(s) 11 08 57 a  m" src="https://github.com/user-attachments/assets/5c06afa4-9b7c-40c9-bcf7-a17e40444b79" />



