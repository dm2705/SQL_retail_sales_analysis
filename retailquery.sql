--Create the table--
CREATE TABLE retail_sales_table
(
transactions_id	INT,
sale_date	DATE,
sale_time	TIME,
customer_id	INT,
gender	VARCHAR(10),
age INT,	
category VARCHAR(15),	
quantity INT,
price_per_unit FLOAT,	
cogs	FLOAT,
total_sale	FLOAT
);

SELECT * FROM retail_sales_table
LIMIT 50;

--Count # of Entries--
SELECT COUNT(*) FROM retail_sales_table;





--DATA CLEANING--

--Identify NULL--
SELECT * FROM retail_sales_table
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR 
	gender IS NULL
	OR 
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--Delete NULL--
DELETE FROM retail_sales_table
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR 
	gender IS NULL
	OR 
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;



--DATA EXPLORATION--

--# of sales--
SELECT COUNT(total_sale) FROM retail_sales_table;

--# of unique customers--
SELECT COUNT(DISTINCT customer_id) FROM retail_sales_table;

--# of unique categories--
SELECT DISTINCT category FROM retail_sales_table;



--ANALYSIS QUERIES--

--Q1. Find columns for sales made on a specific date--
SELECT * FROM retail_sales_table
WHERE sale_date = '2022-10-06';

--Q2. Find specific category and quantity in a certain month--
SELECT * FROM retail_sales_table
WHERE category = 'Clothing'
	AND
	--Adjust it from YYYY-MM-DD to YYYY-MM
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity >= 4;

--Q3. Total sales for each category--
SELECT 
	category,
	SUM(total_sale) AS total
FROM retail_sales_table
GROUP BY 1;

--Q.4 find average age of customers who purchased items from a certain category--
SELECT
	ROUND(AVG(age),2) as average_age
FROM retail_sales_table
WHERE category = 'Beauty';

--Q.5 Transactions where total_sale greater tham 1000--
SELECT * FROM retail_sales_table
WHERE total_sale > 1000;

--Q.6 Transactions in each category by gender--
SELECT
	category,
	gender,
	COUNT(*) as total_transactions
FROM retail_sales_table
GROUP BY 1,2
ORDER BY 1;

--Q.7 Average sale each month, best selling month each year--
SELECT
	year,
	month,
	average_total_sale
FROM
(
	SELECT
		--use EXTRACT function to seperate parts of the date--
		EXTRACT(YEAR from sale_date) as year,
		EXTRACT(MONTH from sale_date) as month,
		AVG(total_sale) as average_total_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
	FROM retail_sales_table
	GROUP by 1,2
) as t1
WHERE rank = 1
ORDER by 1,3 DESC;

--Q.8 Top 5 customers based on highest total sales--
SELECT
	customer_id,
	SUM(total_sale)
FROM retail_sales_table
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Q.9 # of customers in each category--
SELECT
	category,
	COUNT(customer_id)
FROM retail_sales_table
GROUP by 1;

--Q.10 Create transaction shifts during the day and number of orders based on time--
WITH hourly_sales
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales_table
)
SELECT 
	shift,
	COUNT(transactions_id)
FROM hourly_sales
GROUP BY shift;

--ADDITIONAL QUERIES--

--Moving Average Sales 7 Days smoothen short term fluctuations--

SELECT
	sale_date,
	category,
	SUM(total_sale) AS daily_sales,
	AVG(SUM(total_sale)) OVER (
		PARTITION BY category --seperate by category--
		ORDER BY sale_date --chronological order--
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW --6 previous days and current day--
	) AS moving_avg_sales
FROM retail_sales_table
GROUP BY 1, 2
ORDER BY 1;
		
--Sales Trend Forecasting (Linear Regression)--
WITH regression AS (
	SELECT
		category,
		REGR_SLOPE(total_sale, EXTRACT(EPOCH FROM sale_date)) AS trend_slope,
		REGR_INTERCEPT(total_sale, EXTRACT(EPOCH FROM sale_date)) AS trend_intercept
	FROM retail_sales_table
	GROUP BY category
)
SELECT
	category,
	trend_slope * EXTRACT(EPOCH FROM '2023-01-01'::timestamp) + trend_intercept AS predicted_sales_2024
	--take the info and predict sales for the next year in this example, 2023 -> 2024--
FROM regression;

--END OF PROJECT--






