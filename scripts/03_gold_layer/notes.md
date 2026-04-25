# Gold Layer

<img width="1480" height="373" alt="Captura de pantalla 2026-04-23 a la(s) 12 33 15 p  m" src="https://github.com/user-attachments/assets/3ec3235e-7926-4c28-9b8d-35a360ef798a" />
<br><br>
The Gold layer represents the final stage of the data pipeline, where cleaned and integrated data from the Silver layer is transformed into a business-ready model. This layer is designed to support analytical queries, reporting, and decision-making by organizing data into a structured and optimized format.

---
## 📐 Data Modeling Approach

Data models can be designed at different levels of abstraction, each serving a specific purpose in the development process. The three main types are conceptual, logical, and physical data models.
<br><br>
<img width="1099" height="633" alt="Captura de pantalla 2026-04-23 a la(s) 12 40 06 p  m" src="https://github.com/user-attachments/assets/9c8f7dd7-0c6f-4ff1-8a82-5d0819018572" />
<br><br>
In this project, the focus is on the <b>logical data model</b>, which defines the structure of the data, the relationships between entities, and the organization of tables without going into implementation-specific details. This level is ideal for designing analytical models in the Gold layer.

---
## 📊 Star Schema vs Snowflake Schema

Two common approaches for dimensional modeling are the Star Schema and the Snowflake Schema.

<img width="976" height="490" alt="Captura de pantalla 2026-04-24 a la(s) 9 49 09 p  m" src="https://github.com/user-attachments/assets/e31c765f-e170-4566-9219-f3bfcc8daa6a" />
<br><br>

The <b>Star Schema</b> is simple and intuitive, where fact tables are directly connected to dimension tables. Although this approach may introduce some data redundancy, it significantly improves query performance and makes the model easier to understand.

The <b>Snowflake Schema</b> is more normalized and complex, splitting dimension tables into multiple related tables. While it reduces redundancy and can improve storage efficiency, it increases complexity and requires more advanced knowledge to manage and query.

For this project, the <b>Star Schema</b> was selected due to its simplicity, performance advantages, and suitability for analytical workloads.

---
## 🧩 Dimensions vs Facts
In dimensional modeling, data is organized into dimensions and facts.

<img width="1483" height="474" alt="Captura de pantalla 2026-04-23 a la(s) 1 00 25 p  m" src="https://github.com/user-attachments/assets/c1d2cf37-ced0-4a84-86cc-2799e46c2954" />
<br><br>

<b>Dimensions</b> contain descriptive attributes that provide context to the data, such as customer, product, or location information.  

<b>Facts</b> represent measurable events or transactions, such as sales, quantities, or revenue.

This separation allows for efficient querying and supports analytical use cases by combining descriptive and transactional data.

---
## 🔗 Join Strategy

<img width="1093" height="831" src="https://github.com/user-attachments/assets/2babbe2a-f12a-477a-9e25-71d77aad20ee" />
<br><br>

When integrating data across tables, LEFT JOINs are preferred over INNER JOINs. This approach ensures that all primary records (such as customers or transactions) are preserved, even when related data is missing in other tables.

This strategy helps prevent data loss and maintains completeness in the analytical model.

---
## 🔑 Surrogate Keys
<img width="921" height="315" src="https://github.com/user-attachments/assets/7af6095d-87fe-4e00-984b-6cbb251c2135" />
<br><br>

Surrogate keys were introduced in the dimension tables to uniquely identify each record and facilitate relationships within the data model.

For example, a generated <b>customer_key</b> is used instead of relying solely on source system identifiers. This improves consistency, avoids dependency on external systems, and simplifies joins between fact and dimension tables.

---
## 🏗️ Building the Fact Table

<img width="721" height="435" src="https://github.com/user-attachments/assets/46170ec6-bf4c-47bc-91d0-169e58350525" />
<br><br>
The fact table was constructed by integrating transactional data with the corresponding dimension tables using surrogate keys.

Instead of using raw identifiers from source systems, the fact table references <b>dimension surrogate keys</b> (e.g., product_key, customer_key). This ensures a consistent and scalable structure for analytical queries.

---
## 🧱 Data Model Design

<img width="1369" height="710"  src="https://github.com/user-attachments/assets/1cc8ed6d-c22a-4855-ac39-0d9dbe981a5c" />
<br><br>
<img width="1333" height="501" src="https://github.com/user-attachments/assets/394918de-6dae-4f00-887f-a47fb4ca49ef" />
<br><br>

The final data model was designed following a Star Schema structure, where the fact table is centrally connected to dimension tables. This design enables efficient querying and simplifies analytical workflows.

---
## 📚 Data Catalog


A data catalog was created to document the structure of the Gold layer, including table definitions, column descriptions, and relationships.

This documentation improves data transparency, facilitates collaboration, and helps users understand how to effectively use the data model for analysis.

### 1. **gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**
  
<img width="960" height="423" alt="gold.dim_customers" src="https://github.com/user-attachments/assets/8132da32-9006-4b62-b6c2-5f194247eed3" />
<br><br>

### 2. **gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**
  
<img width="1020" height="500" alt="gold.dim_products" src="https://github.com/user-attachments/assets/413ea83a-f803-45af-ac9b-8cece45f9405" />
<br><br>

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**
  
<img width="944" height="382" alt="" src="https://github.com/user-attachments/assets/8d71352d-5607-4521-88e0-7c154c622522" />

---
