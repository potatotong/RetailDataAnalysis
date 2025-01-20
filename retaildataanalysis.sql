-- creating the ProductFinancials table with ProductCost, ProductPrice, and Profit
create table ProductFinancials as
	select
    ProductCost,
    ProductPrice,
    Profit
from retail_data;

-- creating the GenderProductCategory table with Gender, ProductCategory, and PurchaseFrequency (of each product)
CREATE TABLE GenderProductCategory AS
SELECT 
    Gender, 
    ProductCategory, 
    COUNT(*) AS PurchaseFrequency
FROM retail_data
GROUP BY Gender, ProductCategory
ORDER BY Gender, ProductCategory;

-- adding the ProfitMargin column to ProductFinancials
ALTER TABLE ProductFinancials
ADD COLUMN ProfitMargin DECIMAL(10, 2);

-- inserting values into ProfitMargin using the formula
UPDATE ProductFinancials
SET ProfitMargin = Profit / ProductPrice;

-- Creating the table ProfitMarginByDate with PurchaseDate and ProfitMargin
CREATE TABLE ProfitMarginByDate AS
SELECT 
    r.PurchaseDate,
    p.ProfitMargin
FROM retail_data r
JOIN ProductFinancials p
    ON r.ProductPrice = p.ProductPrice
WHERE r.PurchaseDate IS NOT NULL;

-- creating the table ClothingPriceCost with the ProductPrice/Cost of all purchases of the category "Clothing"
CREATE TABLE ClothingPriceCost AS
SELECT 
    ProductPrice AS ClothingPrice,
    ProductCost AS ClothingCost
FROM retail_data
WHERE ProductCategory = 'Clothing';

-- creating table product_avg_marketing with ProductCategory and the average marketing expenditure of each
--   category.
CREATE TABLE product_avg_marketing AS
SELECT
    ProductCategory,
    AVG(MarketingExpenditure) AS AverageMarketingExpenditure
FROM
    retail_data
GROUP BY
    ProductCategory;

-- creating the table WealthByAge with Age, average AnnualIncome, and average SpendingScore
CREATE TABLE WealthByAge AS
SELECT 
    Age, 
    AVG(AnnualIncome) AS AvgIncome, 
    AVG(SpendingScore) AS AvgSpendingScore
FROM retail_data
GROUP BY Age
ORDER BY Age; 

-- creating the table RollingAvgIncomeByAge with Age and rolling average AnnualIncome, taken over 5 rows
CREATE TABLE RollingAvgIncomeByAge AS
SELECT 
    t.Age,
    t.AvgAnnualIncome,
    AVG(t.AvgAnnualIncome) OVER (
        ORDER BY t.Age 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS RollingAvgIncome
FROM (
    SELECT Age, AVG(AnnualIncome) AS AvgAnnualIncome
    FROM retail_data
    GROUP BY Age
) t
ORDER BY t.Age;

-- creating the table numerical_data with all the numerical columns from retail_data
CREATE TABLE numerical_data AS
SELECT Age, AnnualIncome, SpendingScore, ProductPrice, DiscountApplied, DiscountPercent, ProductCost, Profit, FootTraffic, InventoryLevel, MarketingExpenditure, CompetitorPrice
FROM retail_data;

-- creating the table MonthlyRollingProfitMargin with PurchaseDate (renamed to Month),
--   and the monthly average of the rolling average profit margin, taken over 3 rows
CREATE TABLE MonthlyRollingProfitMargin AS
SELECT 
    DATE_FORMAT(PurchaseDate, '%Y-%m') AS Month,
    AVG(ProfitMargin) AS AvgMonthlyMargin,
    AVG(AVG(ProfitMargin)) OVER (
        ORDER BY DATE_FORMAT(PurchaseDate, '%Y-%m') 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS RollingAvgProfitMargin
FROM ProfitMarginByDate
GROUP BY DATE_FORMAT(PurchaseDate, '%Y-%m');

-- creating the table lookup_city with two columns: City, and State
create table lookup_city (
	City VARCHAR(100) NOT NULL,
    State VARCHAR(2) NOT NULL
);

-- updating the lookup_city table with cities found in retail_data
INSERT INTO lookup_city (City, State)
VALUES
	('New York', 'NY'),
    ('Dallas', 'TX'),
    ('Philadelphia', 'PA'),
    ('Chicago', 'IL'),
    ('San Antonio', 'TX'),
    ('Los Angeles', 'CA'),
    ('San Diego', 'CA'),
    ('Phoenix', 'AZ'),
    ('Houston', 'TX'),
    ('San Jose', 'CA');
    
-- creating the table store_locations with StoreLocation 
CREATE TABLE store_locations AS
SELECT StoreLocation
FROM retail_data;

-- replacing the StoreLocation city names with the corresponding state abbreviations
--   in lookup_city
UPDATE store_locations AS s
JOIN lookup_city AS c
ON s.StoreLocation = c.City
SET s.StoreLocation = c.State;

