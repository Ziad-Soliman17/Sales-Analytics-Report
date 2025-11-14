USE AdventureWorksDW2019
GO

--Sales Fact Table--
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

--Date Dimension Table--
SELECT 
	DateKey,
	FullDateAlternateKey,
	CalendarYear,
	LEFT(EnglishMonthName,3) AS Month_Abbrv,
	MonthNumberOfYear AS Month_NR,
FROM DimDate 
WHERE YEAR(FullDateAlternateKey) BETWEEN 2022 AND 2024


-- Channel type Dimenison Table 
SELECT
	ResellerKey AS ChannelKey,
	'Retail' AS Channel_Type
FROM DimReseller
Union ALL
SELECT 
	CustomerKey,
	'Online'
from DimCustomer


-- Customer Dimenison  Table --
Select
	CustomerKey,
	CONCAT (FirstName,' ',LastName) AS CustomerName,
	g.EnglishCountryRegionName AS Country  
From DimCustomer c
LEFT JOIN DimGeography g ON c.GeographyKey = g.GeographyKey ;


-- Resller Dimension Table --
Select 
	r.ResellerKey,
	r.ResellerName,
	g.EnglishCountryRegionName AS Country
From DimReseller r
LEFT JOIN DimGeography g ON r.GeographyKey = g.GeographyKey ;

-- Product Dimension Table--
SELECT
	p.ProductKey,
	p.EnglishProductName AS ProductName,
	COALESCE(s.EnglishProductSubcategoryName, 'Others') AS Subcategory,
	COALESCE(c.EnglishProductCategoryName, 'Others') AS Catgeory
FROM DimProduct p
LEFT JOIN DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey 
WHERE FinishedGoodsFlag = 1 ;


--Dimension Sales Territory Table--
SELECT
	SalesTerritoryKey,
	SalesTerritoryCountry
FROM DimSalesTerritory ;


