-- A - 10 sql analytical queries demonstrating mastery of dimensional concepts:
-- 1 - Time based trend analysis:

-- Year-over-year growth analysis
-- we do not have a dim table for dates, so we need to
-- extract and convert
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY year
ORDER BY year;

-- Seasonal pattern identification
SELECT
	TO_CHAR(order_purchase_timestamp::timestamp, 'Month') AS month_name,
	EXTRACT(MONTH FROM order_purchase_timestamp::timestamp) AS month_number,
	ROUND(AVG(foi.price + foi.freight_value), 2) AS avg_monthly_revenue
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY month_name, month_number
ORDER BY month_number;

-- 2 - Drill-down and Roll-up Operations:
-- Multi-level aggregation (roll-up)
-- roll-up is "zooming out" and summarizing
-- roll-up revenue by day:
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
	EXTRACT(MONTH FROM order_purchase_timestamp::timestamp) AS month,
	EXTRACT(DAY FROM order_purchase_timestamp::timestamp) AS day,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY year, month, day
ORDER BY year, month, day;

-- roll-up revenue by month:
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
	EXTRACT(MONTH FROM order_purchase_timestamp::timestamp) AS month,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY year, month
ORDER BY year, month;

-- roll-up revenue by year:
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY year
ORDER BY year;

-- Seasonal pattern identification (drill-down)
-- drill-down is to inspect details
-- revenue by city
SELECT
	dc.customer_state,
	dc.customer_city,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN dim_customer dc
	ON fo.seq_customer_sk = dc.seq_customer_sk
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY dc.customer_state, dc.customer_city
ORDER BY dc.customer_state, dc.customer_city;


-- revenue by state
SELECT
	dc.customer_state,
	SUM(foi.price + foi.freight_value) AS total_revenue
FROM fact_order fo
JOIN dim_customer dc
	ON fo.seq_customer_sk = dc.seq_customer_sk
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
GROUP BY dc.customer_state
ORDER BY dc.customer_state;

-- 3 - Advanced window function:
-- Ranking percentile calculations
-- Rank sellers by total revenue
SELECT
	ds.seller_id,
	SUM(foi.price + foi.freight_value) AS total_revenue,
	RANK() OVER (ORDER BY SUM(foi.price + foi.freight_value) DESC) AS revenue_rank,
	PERCENT_RANK() OVER (ORDER BY SUM(foi.price + foi.freight_value) DESC) AS revenue_rank_percentile
FROM fact_order fo
JOIN fact_order_item foi
	ON fo.seq_order_sk = foi.seq_order_sk
JOIN dim_seller ds 
	ON foi.seq_seller_sk = ds.seq_seller_sk
WHERE EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) IN (2016, 2017, 2018)
GROUP BY ds.seller_id
ORDER BY revenue_rank;

-- gpt-endring (between)
SELECT
    ds.seller_id,
    SUM(foi.price + foi.freight_value) AS total_revenue,
    RANK() OVER (ORDER BY SUM(foi.price + foi.freight_value) DESC) AS revenue_rank,
    PERCENT_RANK() OVER (ORDER BY SUM(foi.price + foi.freight_value) DESC) AS revenue_percentile
FROM fact_order fo
JOIN fact_order_item foi 
	ON fo.seq_order_sk = foi.seq_order_sk
JOIN dim_seller ds 
	ON foi.seq_seller_sk = ds.seq_seller_sk
WHERE EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) BETWEEN 2016 AND 2018
GROUP BY ds.seller_id;


-- Moving averages and cumulative measures
-- tenker avg incoming orders per day of a seven day period or smth

SELECT 
	COUNT(fo.order_id) AS incoming_orders,
	-- EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) AS year,
	-- EXTRACT(MONTH FROM fo.order_purchase_timestamp::timestamp) AS month,
	EXTRACT(DAY FROM fo.order_purchase_timestamp::timestamp) AS day
FROM fact_order fo
WHERE EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) IN (2017)
	AND EXTRACT(MONTH FROM fo.order_purchase_timestamp::timestamp) IN (10)
	AND EXTRACT(DAY FROM fo.order_purchase_timestamp::timestamp) IN (2,3,4,5,6,7,8)
GROUP BY day
LIMIT 10;

-- Moving Average & Cumulative Total of Daily Orders
WITH daily_orders AS (
    SELECT
        DATE(fo.order_purchase_timestamp) AS order_date,
        COUNT(*) AS daily_order_count
    FROM fact_order fo
    WHERE EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) = 2017
    GROUP BY DATE(fo.order_purchase_timestamp)
)

SELECT
    order_date,
    daily_order_count,
    -- 7-day moving average of daily order count
    ROUND(AVG(daily_order_count) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_7d,
    
    -- Cumulative total orders up to current date
    SUM(daily_order_count) OVER (
        ORDER BY order_date
    ) AS cumulative_orders
FROM daily_orders
ORDER BY order_date;
-- SELECT * FROM fact_order LIMIT 10
-- EXTRACT(YEAR, MONTH, DAY FROM fo.order_purchase_timestamp::timestamp)


-- 4 - Complex filtering and subqueries
-- Multi-dimensional filtering with EXISTS/IN clauses
SELECT dp.*
FROM dim_product dp

SELECT dp.product_id, dp.product_category_name
FROM dim_product dp
WHERE dp.seq_product_sk IN (
	SELECT foi.seq_product_sk
	FROM fact_order_item foi
	JOIN fact_order fo ON foi.seq_order_sk = fo.seq_order_sk
	JOIN dim_customer dc ON fo.seq_customer_sk = dc.seq_customer_sk
	GROUP BY foi.seq_product_sk
	HAVING COUNT(DISTINCT dc.customer_city) > 150
);

-- Correlated subqueries for comparative analysis
-- products with better reviews than average
SELECT 
    dp.product_category_name,
    dp.product_id,
    ROUND(AVG(fr.review_score), 2) AS avg_product_score
FROM fact_review fr
JOIN fact_order fo 
	ON fr.seq_order_sk = fo.seq_order_sk
JOIN fact_order_item foi 
	ON fo.seq_order_sk = foi.seq_order_sk
JOIN dim_product dp 
	ON foi.seq_product_sk = dp.seq_product_sk
GROUP BY dp.product_category_name, dp.product_id
HAVING AVG(fr.review_score) > (
    SELECT AVG(review_score) 
    FROM fact_review
)
ORDER BY avg_product_score DESC;

-- Business Intelligence Metrics
-- Customer/Product profitability analysis
SELECT 
    dp.product_category_name,
    ROUND(SUM(foi.price), 2) AS total_revenue,
    ROUND(SUM(foi.freight_value), 2) AS total_freight_cost,
    ROUND(SUM(foi.price - foi.freight_value), 2) AS profitability
FROM fact_order_item foi
JOIN dim_product dp 
    ON foi.seq_product_sk = dp.seq_product_sk
GROUP BY dp.product_category_name
ORDER BY profitability DESC;


-- Performance KPI calculations specific to your domain
-- delivery time and ratio
SELECT 
    EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) AS year,
    EXTRACT(MONTH FROM fo.order_purchase_timestamp::timestamp) AS month,
    ROUND(AVG(EXTRACT(EPOCH FROM (fo.order_delivered_customer_date - fo.order_purchase_timestamp::timestamp)) / (60*60*24)), 2) AS avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN fo.order_delivered_customer_date <= fo.order_estimated_delivery_date THEN 1 ELSE 0 END) 
          / COUNT(*), 2) AS on_time_delivery_pct
FROM fact_order fo
WHERE fo.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;

-- profits over time
SELECT 
    EXTRACT(YEAR FROM fo.order_purchase_timestamp::timestamp) AS year,
    EXTRACT(MONTH FROM fo.order_purchase_timestamp::timestamp) AS month,
    ROUND(SUM(foi.price - foi.freight_value), 2) AS monthly_profitability
FROM fact_order_item foi
JOIN fact_order fo 
    ON foi.seq_order_sk = fo.seq_order_sk
WHERE fo.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;