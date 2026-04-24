
# Gold Layer

<img width="1480" height="373" alt="Captura de pantalla 2026-04-23 a la(s) 12 33 15 p  m" src="https://github.com/user-attachments/assets/3ec3235e-7926-4c28-9b8d-35a360ef798a" />

<br><br>

In Data Model we have 3 different ways in how to draw a data model

<img width="1486" height="827" alt="Captura de pantalla 2026-04-23 a la(s) 12 39 21 p  m" src="https://github.com/user-attachments/assets/400adbe1-f038-4694-b99b-e27476449db7" />

- Conceptual data model  <br>
- Logical data model       <br>
- physical data model        <br>

<br><br>

<img width="1099" height="633" alt="Captura de pantalla 2026-04-23 a la(s) 12 40 06 p  m" src="https://github.com/user-attachments/assets/9c8f7dd7-0c6f-4ff1-8a82-5d0819018572" />

In this project we are going to draw the logical data model for the gold layer 


## Theory 

### Start schema vs Snowflake schema 

<img width="718" height="827" alt="Captura de pantalla 2026-04-23 a la(s) 1 27 23 p  m" src="https://github.com/user-attachments/assets/07187663-2343-4852-b9db-523c223af037" />

- The start schema is easy to understand but it the dimensions should contain duplicates and this get bigger
with the time


<img width="676" height="821" alt="Captura de pantalla 2026-04-23 a la(s) 1 28 25 p  m" src="https://github.com/user-attachments/assets/2ee9da5a-5524-4f29-ac8b-c0d706433bbf" />

- the Snowflake schema: it is more complex, require a lot knowleges, the data is more large bacause is more
- detail but the optimization is better

  In this project we;re going to use the start schema


### Dimensions Vs Facts 

<img width="1483" height="474" alt="Captura de pantalla 2026-04-23 a la(s) 1 00 25 p  m" src="https://github.com/user-attachments/assets/c1d2cf37-ced0-4a84-86cc-2799e46c2954" />

- Dimensions - Details <br>
Facts - transaccions      <br>

## Join

Try to avoid the inner join when you are going to join table, because somentimes the other tables don't 
all the informacion 

<img width="1093" height="831" alt="Captura de pantalla 2026-04-23 a la(s) 1 50 12 p  m" src="https://github.com/user-attachments/assets/2babbe2a-f12a-477a-9e25-71d77aad20ee" />

## Surrogate Key 

For the dimention of custumer table the surrogate key is - custumer id to conect the data model. 



<img width="921" height="315" alt="Captura de pantalla 2026-04-24 a la(s) 12 09 23 p  m" src="https://github.com/user-attachments/assets/7af6095d-87fe-4e00-984b-6cbb251c2135" />

## Building Fact

-- Building FACT 
-- Use the dimension´s surrogate keys instead of IDs to easily connect facts with dimensions 

<img width="721" height="435" alt="Captura de pantalla 2026-04-24 a la(s) 1 18 51 p  m" src="https://github.com/user-attachments/assets/46170ec6-bf4c-47bc-91d0-169e58350525" />







  

- 
