DROP DATABASE walmartsales;
CREATE DATABASE IF NOT EXISTS walmartsales;

USE WALMARTSALES;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VTA FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

SELECT * FROM sales;

-- -------------------------------------------------------------------------------
-- -------------------FEATURE ENGINEERING-----------------------------------------
-- -------------------------------------------------------------------------------

-- --adding a column 'time_of_day' to show morning,afternoon,evening -------------

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day =(
	CASE
		WHEN time BETWEEN "00:00:00" AND "11:59:59" THEN "Morning"
        WHEN time BETWEEN "12:00:00" AND "15:59:59" THEN "Afternoon"
        ELSE "Evening"
	END
    );

SELECT * FROM sales;

-- --creating a column 'day_name' to get the day of the specific date-------------

SELECT date,DAYNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);
UPDATE sales SET day_name = DAYNAME(date);

SELECT * FROM sales;

-- --creating a column 'month_name' to get the month of specific date-------------

SELECT date,MONTHNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);
UPDATE sales SET month_name = MONTHNAME(date);

SELECT * FROM sales;

-- -------------------------------------------------------------------------------
-- ------------------------GENERIC QUESTIONS--------------------------------------
-- -------------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;
SELECT DISTINCT city, COUNT(city) as sales_from_city FROM sales GROUP BY city;

-- In which city is each branch?
SELECT DISTINCT branch,city FROM sales;
SELECT DISTINCT city,branch FROM sales;

-- --------------------------------------------------------------------------------
-- -------------------------PRODUCT------------------------------------------------
-- --------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;
SELECT COUNT(DISTINCT product_line) FROM sales;

-- What is the most common payment method?
SELECT 
	DISTINCT payment_method,COUNT(payment_method) AS payment_counts 
    FROM sales 
    GROUP BY payment_method
    ORDER BY payment_counts 
    DESC;

-- What is the most selling product line?
SELECT 
	DISTINCT product_line, COUNT(product_line) AS most_selling
    FROM sales 
    GROUP BY product_line
    ORDER BY most_selling 
    DESC;

-- What is the total revenue by month?
SELECT 
DISTINCT month_name,sum(total) AS total_revenue
FROM sales 
GROUP BY month_name
ORDER BY total_revenue 
DESC;

-- What month had the largest COGS?
SELECT 
	DISTINCT month_name,SUM(cogs) AS scogs 
    FROM sales 
    GROUP BY month_name 
    ORDER BY scogs 
    DESC;

-- What product line had the largest revenue?
SELECT 
	DISTINCT product_line, SUM(total) as revenue
    FROM sales 
    GROUP BY product_line
    ORDER BY revenue
    DESC
    LIMIT 1;
    
-- What is the city with the largest revenue?
SELECT 
	DISTINCT city,sum(total) as revenue
    FROM sales
    GROUP BY city
    ORDER BY revenue
    DESC
    LIMIT 1;
    
-- What product line had the largest VAT?
SELECT 
	DISTINCT product_line,AVG(VTA) as avg_tax
    FROM sales 
    GROUP BY product_line
    ORDER BY avg_tax
    DESC
    LIMIT 1;
    
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT DISTINCT product_line,SUM(total) AS revenue,AVG(total) as avg_sales,
	(CASE
		WHEN SUM(total) > AVG(total) THEN "Good"
        ELSE "Bad"
	END) AS rating
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT DISTINCT branch, SUM(quantity) AS total_sold
FROM sales 
GROUP BY branch
HAVING total_sold >(SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT 
	product_line,gender,COUNT(gender) as gender_count
    FROM sales 
    GROUP BY product_line,gender 
    ORDER BY gender_count 
    DESC;
    
-- What is the average rating of each product line?
SELECT DISTINCT product_line,ROUND(AVG(rating),1) as avg_rating 
	FROM sales 
	GROUP BY product_line 
	ORDER BY avg_rating 
	DESC;
    
-- ---------------------------------------------------------------------
-- -------------------  SALES  -----------------------------------------
-- ---------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday.
SELECT time_of_day, COUNT(*) as sales_count
FROM sales
GROUP BY time_of_day
ORDER BY sales_count;

SELECT time_of_day, COUNT(*) as sales_count
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY sales_count;

SELECT time_of_day, day_name AS weekdays , COUNT(day_name) as sales_made
FROM sales
GROUP BY time_of_day,weekdays
ORDER BY weekdays,sales_made DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) as revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue
DESC;    
    
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city,
	AVG(VTA) AS avg_of_VAT
FROM sales
GROUP BY city
ORDER BY avg_of_VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(VTA) as avg_vat
FROM sales
GROUP BY customer_type
ORDER BY avg_vat DESC;

-- ----------------------------------------------------------------------------------------
-- ---------------- CUSTOMER --------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT 
COUNT(DISTINCT(customer_type)) AS customer_types
FROM sales;

SELECT 
DISTINCT(customer_type) AS customer_types
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
DISTINCT(payment_method) as payment_methods
FROM sales;

-- What is the most common customer type?
SELECT 
DISTINCT customer_type, COUNT(customer_type) as cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;
    
-- Which customer type buys the most?
SELECT 
DISTINCT customer_type,COUNT(*) AS buys 
FROM sales 
GROUP BY customer_type
ORDER BY buys DESC;

SELECT 
DISTINCT customer_type,SUM(quantity) AS quantity_bought , SUM(total) AS spent
FROM sales
GROUP BY customer_type
ORDER BY spent DESC;    

-- What is the gender of most of the customers?
SELECT DISTINCT gender, COUNT(gender) as customers
FROM sales
GROUP BY gender
ORDER BY customers DESC;

-- What is the gender distribution per branch?
SELECT DISTINCT branch, gender, COUNT(gender) AS cnt
FROM sales
GROUP BY branch,gender
ORDER BY branch;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) as ratings
FROM sales
GROUP BY time_of_day
ORDER BY ratings DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, branch, AVG(rating) as ratings
FROM sales
GROUP BY time_of_day,branch
ORDER BY ratings DESC;
    
-- Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) as ratings
FROM sales
GROUP BY day_name
ORDER BY ratings DESC;

-- Which day of the week has the best average ratings per branch?
SELECT  branch,day_name, AVG(rating) as ratings
FROM sales
GROUP BY branch,day_name
ORDER BY ratings DESC
LIMIT 3;
    
    
    
    
    
    
    
    
    
    