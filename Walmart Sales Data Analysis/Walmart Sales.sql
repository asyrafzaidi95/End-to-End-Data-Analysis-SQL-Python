SELECT * FROM walmart;

SELECT COUNT (*) FROM walmart;

SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT
	COUNT(DISTINCT branch)	
FROM walmart;

SELECT MIN(quantity) FROM walmart

-- Business Problems
--Q1: Find different payment method and number of transactions, number of qty sold

SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- Q2: Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT branch, category, avg_rating
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY Branch,category
) AS ranked
WHERE rank = 1

-- Q3: Determine the busiest day for each branch

SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DATENAME(WEEKDAY, TRY_CONVERT(date, [date], 3)) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, DATENAME(WEEKDAY, TRY_CONVERT(date, [date], 3))
) AS ranked
WHERE rank = 1;

-- Q4: Calculate Total Quantity Sold by Payment Method

SELECT 
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--Q5: Analyze Category Ratings by City

SELECT
	City,
	category,
	AVG (rating) as avg_rating,
	MIN (rating) as min_rating,
	MAX (rating) as max_rating
FROM walmart
GROUP BY City,category

--Q6: Calculate Total Profit by Category

SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
	
--Q7: Determine the Most Common Payment Method per branch

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN DATEPART(HOUR, CAST([time] AS TIME)) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, CAST([time] AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch,
         CASE 
             WHEN DATEPART(HOUR, CAST([time] AS TIME)) < 12 THEN 'Morning'
             WHEN DATEPART(HOUR, CAST([time] AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
         END
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(TRY_CONVERT(date, [date], 3)) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(TRY_CONVERT(date, [date], 3)) = 2023
    GROUP BY branch
)
SELECT TOP 5
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) * 100.0 / r2022.revenue), 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 
ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC

