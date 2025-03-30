# SQL_retail_sales_analysis

## Project Overview

**Project Title**: SQL Retail Sales Analysis  
**Database**: CSV file included in the repo

This project showcases essential SQL skills and techniques commonly used by data analysts to examine, clean, and interpret retail sales data. It includes setting up a retail sales database, conducting exploratory data analysis (EDA), and using SQL queries to address key business questions.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database in pgAdmin
2. **Data Cleaning**: Locate and remove null values so all of the data left is usable
3. **Exploratory Data Analysis (EDA)**: Understand the dataset
4. **Business Analysis**: Answer specific business questions to find statistics and information based on customer activity

## Project Structure

### 1. Database/ Table Setup

```sql
CREATE TABLE retail_sales_table (
    transactions_id INT,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,  
    category VARCHAR(15),  
    quantity INT,
    price_per_unit FLOAT,  
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Records**: Determine the total number of records in the dataset.
```sql
SELECT COUNT(*) FROM retail_sales_table;
```

- **Categories**: Identify all unique product categories in the dataset.
```sql
SELECT DISTINCT category FROM retail_sales_table;
```

- **Customers: Number of customers with unique ID's.
```sql
SELECT COUNT(DISTINCT customer_id) FROM retail_sales_table;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Find columns for sales made on a specific date**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-06';
```

2. **Find specific category and quantity in a certain month**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4
```

3. **Total sales for each category.**:
```sql
SELECT 
	category,
	SUM(total_sale) AS total
FROM retail_sales_table
GROUP BY 1;
```

4. **Find average age of customers who purchased items from a certain category**:
```sql
SELECT
	ROUND(AVG(age),2) as average_age
FROM retail_sales_table
WHERE category = 'Beauty';
```

5. **Transactions where total_sale greater tham 1000**:
```sql
SELECT * FROM retail_sales_table
WHERE total_sale > 1000;
```

6. **Transactions in each category by gender**:
```sql
SELECT
	category,
	gender,
	COUNT(*) as total_transactions
FROM retail_sales_table
GROUP BY 1,2
ORDER BY 1;
```

7. **Average sale each month, best selling month each year**:
```sql
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
```

8. **Top 5 customers based on highest total sales**:
```sql
SELECT
	customer_id,
	SUM(total_sale)
FROM retail_sales_table
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **# of customers in each category**:
```sql
SELECT
	category,
	COUNT(customer_id)
FROM retail_sales_table
GROUP by 1;
```

10. **Create transaction shifts during the day and number of orders based on time**:
```sql
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
```

## Additional Complex Queries

1. **Moving Average Sales 7 Days smoothen short term fluctuations**:
```sql
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
```
2. **Sales Trend Forecasting (Linear Regression)**:
```sql
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
```


## Findings

- **Customer Demographics**: The dataset features customers spanning various age ranges, with sales spread across categories like Clothing and Beauty.
- **High-Value Transactions**: A number of transactions exceeded 1000 in total value, highlighting high-end purchases.
- **Sales Trends**: Monthly reviews reveal fluctuations in sales, assisting in pinpointing peak seasons. 
- **Customer Insights**: The analysis highlights the highest-spending customers and the most sought-after product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

**Further Connections**: Can connect pgAdmin4 PostgreSQL editor to Tableau or Power BI to create data visuals such as graphs to report findings. 

