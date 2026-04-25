/*
This script initializes a Data Warehouse environment.
It creates a database and three schemas:
- bronze (raw data)
- silver (cleaned data)
- gold (business-ready data)
*/

-- Switch context to the master database (default system database)
USE master;
GO

-- Create a new database called DataWarehouse
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the newly created DataWarehouse database
USE DataWarehouse;
GO

-- Create schema for raw data (bronze layer - initial ingestion)
CREATE SCHEMA bronze;
GO

-- Create schema for cleaned and transformed data (silver layer)
CREATE SCHEMA silver;
GO

-- Create schema for curated, business-ready data (gold layer)
CREATE SCHEMA gold;
GO
