# Sales Analytics Report

A comprehensive data analytics project using SQL, Power BI, and DAX for sales performance analysis with products and channel insights using AdventureWorks data warehouse.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white) ![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black) ![DAX](https://img.shields.io/badge/DAX-blue?style=for-the-badge)

![Project Banner](./images/Sales%20Analytics%20Report%20-1.png)
![Project Banner](./images/Sales%20Analytics%20Report%20-2.png)
![Project Banner](./images/Sales%20Analytics%20Report%20-3.png)

## Project Overview

this project delivers an interactive Sales Analytics Report that provides a complete overview of the company’s sales performance across different channels, regions, products, and time periods. The report combines data extraction using SQL, data modeling in Power BI, and DAX calculations to deliver actionable insights for business decision-making.

-----

## Data Extraction and Preparation with SQL

The following SQL queries were used to extract and prepare data from the AdventureWorks database for analysis in Power BI.

- Sales Fact Table 
  
```sql
SELECT
	SalesOrderNumber,
	OrderDateKey AS DateKey,
	ProductKey,
	CustomerKey AS ChannelKey,
	SalesTerritoryKey,
	OrderQuantity,
	ProductStandardCost,
	SalesAmount,
	TaxAmt,
	CAST(OrderDate AS DATE) AS OrderDate
FROM FactInternetSales
WHERE OrderDate IS NOT NULL 
	AND Year(OrderDate) Between 2022 AND 2024
UNION ALL  
SELECT 
	SalesOrderNumber,
	OrderDateKey AS DateKey,
	ProductKey,
	ResellerKey AS ChannelKey,
	SalesTerritoryKey,
	OrderQuantity,
	ProductStandardCost,
	SalesAmount,
	TaxAmt,
	CAST(OrderDate AS DATE) AS OrderDate
FROM 
FactResellerSales
WHERE OrderDate IS NOT NULL 
	AND Year(OrderDate) Between 2022 AND 2024
```

- Date Dimension Table
  
```sql
SELECT 
	DateKey,
	FullDateAlternateKey,
	CalendarYear,
	LEFT(EnglishMonthName,3) AS Month_Abbrv,
	MonthNumberOfYear AS Month_NR
FROM DimDate 
WHERE YEAR(FullDateAlternateKey) BETWEEN 2022 AND 2024;
```

- Channel Dimension Table
  
```sql
SELECT
	ResellerKey AS ChannelKey,
	'Retail' AS Channel_Type
FROM DimReseller
Union ALL
SELECT 
	CustomerKey,
	'Online'
from DimCustomer
```

- Customer Dimension Table
  
```sql
Select
	CustomerKey,
	CONCAT (FirstName,' ',LastName) AS CustomerName,
	g.EnglishCountryRegionName AS Country  
From DimCustomer c
LEFT JOIN DimGeography g ON c.GeographyKey = g.GeographyKey ;
```

- Reseller Dimension Table 
  
```sql
Select 
	r.ResellerKey,
	r.ResellerName,
	g.EnglishCountryRegionName AS Country
From DimReseller r
LEFT JOIN DimGeography g ON r.GeographyKey = g.GeographyKey;
```

- Product Dimension Table
  
```sql
SELECT
	p.ProductKey,
	p.EnglishProductName AS ProductName,
	COALESCE(s.EnglishProductSubcategoryName, 'Others') AS Subcategory,
	COALESCE(c.EnglishProductCategoryName, 'Others') AS Catgeory
FROM DimProduct p
LEFT JOIN DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey 
WHERE FinishedGoodsFlag = 1;
```

- Dimension Sales Territory Table
  
```sql
SELECT
	SalesTerritoryKey,
	SalesTerritoryCountry
FROM DimSalesTerritory;
```

-----

## Data Model

### Star Schema Design

The data model follows a star schema architecture for optimal query performance:

**Fact Tables:**

- `FactSales` - Transactional sales data

**Dimension Tables:**

- `DimProduct` - Product catalog and categories
- `DimDate` - Date dimension for time-based analysis
- `DimSalesTerritory` - Geographic information
- `DimChannel` - Sales channel Types
- `DimReseller` - Reseller information
- `DimCustomer` - Customer information
  
### Relationships

```

- Sales[ProductKey] → Products[ProductKey] (Many-to-One)
- Sales[OrderDateKey] → Date[DateKey] (Many-to-One)
- SalesTerritory[SalesTerritoryKey] → Sales[SalesTerritoryKey] (Many-to-One)
- Sales[ChannelKey] → Channel[ChannelKey] (Many-to-One)
- Channel[ChannelKey] → Reseller[ResellerKey] (one-to-One)
- Channel[ChannelKey] → Customer[CustomerKey] (one-to-One)
```

![Project Banner](./images/Data%20Model.jpeg)

-----

## DAX Measures

### Sales Measures
```dax
//Net Sales
Net Sales = SUMX(Sales_fact, Sales_fact[SalesAmount] - Sales_fact[TaxAmt])

// Previous Year Sales
Previous Year Sales = 
VAR MaxYear = Max(Date_dim[CalendarYear])
VAR PrevYear = MaxYear - 1
RETURN
CALCULATE(
    [Net Sales],
    FILTER(ALL(Date_dim), Date_dim[CalendarYear] = PrevYear)
)
```

### Profitability Measures

```dax
// Total Cost
Total Cost = SUM(Sales_fact[ProductStandardCost])

// Net Profit
Net Profit = [Net Sales] - [Total Cost]

// Profit Margin%
Profit Margin = DIVIDE( [Net Profit], [Net Sales],0)
```

### Time Intelligence Measures

```dax
// Year-over-Year Growth
Sales YoY % = DIVIDE( [Net Sales]-[Previous Year Sales] ,[Previous Year Sales],0)

// Month-over-Month Growth
Sales MoM % = 
VAR Curr = [Net Sales]
VAR Prev =
    CALCULATE(
        [Net Sales],
        PREVIOUSMONTH('Date_dim'[Date])
    )
RETURN
IF(
    NOT ISBLANK(Prev) && Prev <> 0,
    DIVIDE(Curr - Prev, Prev)
)
```

### Quantity Measure

```dax
// Total Quantity Sold
Total Quantity Sold = SUM(Sales_fact[OrderQuantity])
```

### Order Measures

```dax
//Total Orders
Total Orders = DISTINCTCOUNT(Sales_fact[SalesOrderNumber])

// Average Order Value
Average Order Value = DIVIDE( [Net Sales], [Total Orders],0)
```

-----

## Data Visualization

### Dashboard Overview

The Power BI dashboard consists of multiple interactive pages:

#### 1. Sales Overview

![Project Banner](./images/Sales%20Analytics%20Report%20-1.png)

Purpose: High-level KPI monitoring and trend analysis
Key Visualizations:

- KPI Cards: Net Sales ($48.4M), Net Profit ($26.6M), Total Quantity (166K), Total Orders (23K), Average Order Value ($2.1K)
- Line Chart: Sales Trend with MoM % Analysis (showing monthly performance with growth indicators)
- Combo Chart: Net Profit and Profit Margin Trend (dual-axis visualization)
- Donut Chart: Sales by Channel (Retail 68.91% vs Online 31.09%)
- - Bar Chart: Sales by Category (Bikes: $41M, Components: $6M, Clothing: $1M, Accessories: $1M)
- Map Visual: Geographic sales distribution across 5 countries

#### 2. Product Details

![Project Banner](./images/Sales%20Analytics%20Report%20-2.png)

Purpose: Deep-dive analysis of product performance and profitability Per Category level.

Key Visualizations:

- Filter buttons for Category Selection (Bikes, Components, Clothing, Accessories)
- Bar Chart: Top 10 Products by Sales (Sale-focused ranking)
- Bar Chart: Top 10 Products by Quantity (horizontal bar chart showing volume leaders)
- Table: Top 10 Products with detailed metrics (Cost, Sales, Sales YoY%, Net Profit, Profit Margin%, Quantity Sold, Quantity YoY%, Orders)


#### 3. Channel Details

![Project Banner](./images/Sales%20Analytics%20Report%20-3.png)

Purpose: Channel performance analysis and channel strategy insights
Key Visualizations:

- Filter buttons for Channel Selection (Retail vs Online)
- Bar Chart: Top 10 Resellers / Customers by Sales
-Map Visual: Distribution of Resellers / Customers across Countries
- Matrix Table: Reseller / Customer performance metrics (Country, Sales, Profit, Profit Margin, Quantity Sold, Orders, Average Order Value)

-----

## Contact Information

- Email: <ziad.mohamed17.1@gmail.com>
- LinkedIn: [www.linkedin.com/in/ziadsoliman](www.linkedin.com/in/ziadsoliman)

-----

## Resources

- AdventureWorks Database: [Microsoft SQL Samples](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms)

-----