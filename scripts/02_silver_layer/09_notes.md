# Silver Layer 

<img width="1253" height="180" src="https://github.com/user-attachments/assets/e991532b-f21b-499a-8acd-1e0578a628aa" />
<br>
<br>

---
## 🔍  Analysing: Explore & Understand Data

<p align="justify"> A critical first step in the Silver layer is to explore and fully understand the source data. This includes identifying data structures, column meanings, data quality issues, and relationships between tables. <br><br> One effective way to organize this analysis is by creating a <b>data integration map</b>. This helps identify the key fields (business keys) that connect tables across systems and ensures consistency in downstream transformations. </p>

### Exploring the tables: 

<img width="332" height="80" alt="Exploring the tables_1" src="https://github.com/user-attachments/assets/00b02776-8c3d-4c16-b269-254cd6923447" />
<br>
<img width="471" height="56" alt="Exploring the tables_2" src="https://github.com/user-attachments/assets/5508e0ca-4c6c-4c79-bd98-4d1f5ea418bc" />
<br>

During this phase, each table is reviewed to: 

- Understand column definitions and data types
- Identify primary keys and potential duplicates
- Detect null values and data inconsistencies
- Recognize relationships between datasets

---
## 📐  Draw Data Integration (Draw.io)
<p align="justify"> After reviewing the tables, the <b>common keys and relationships</b> between datasets were identified. <br><br> These relationships were then visualized using a data integration diagram, which serves as a reference for how data flows and connects across different tables. </p>
<br>
<img width="1352" height="756" alt="Data Integration" src="https://github.com/user-attachments/assets/a8536140-8db3-40da-9b1e-e9274fc29733" />

---
## 🔧 Types of Transformations Applied 

1. **Data Cleaning & Normalization**  
   Data was cleaned by removing extra spaces, hidden characters (tabs, line breaks), and standardizing formats using functions such as `TRIM`, `UPPER`, and `REPLACE`.  

   ➜ This ensures consistency and prevents errors in joins and comparisons.

3. **Handling Missing & Invalid Values**  
   Null or incorrect values were handled using business rules (`ISNULL`, `CASE`), including fixing invalid dates and negative values.  

    ➜ This makes the data usable for analysis without errors.

5. **Data Type Casting**  
   Columns were converted to appropriate data types, especially dates (`CAST AS DATE`).  

   ➜ This enables reliable filtering, calculations, and time-based analysis.

7. **Derived Columns & Key Standardization**  
   New columns (such as `cat_id`) were created, and keys (`cid`, `prd_key`) were standardized to enable proper data integration across tables.  

   ➜ This improves relationships between datasets and overall model structure.

9. **Data Enrichment (Business-Friendly Values)**  
   Codes were transformed into descriptive values (`M → Mountain`, `F → Female`).  

    ➜ This makes the data more understandable and useful for business users.

11. **Temporal Data Handling**  
   Date ranges were adjusted using functions like `LEAD()` and `DATEADD()` to avoid overlaps and identify current records.  

    ➜ This allows correct handling of historical and current data.

13. **Data Quality Validation**  
   Checks were performed to identify duplicates, inconsistencies, and data issues before final loading.

   ➜ This ensures data integrity and reliability of the model.

---

## 🎯 Result

These transformations convert raw and inconsistent data into a clean, integrated, and analytics-ready data model.
