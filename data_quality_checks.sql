/* =====================================================
DATA QUALITY ASSESSMENT
Author: Claudenilson Junior
Purpose: Identify inconsistencies before analysis
===================================================== */

/* =====================================================
TABLE: Customers
DATA QUALITY CHECKS

Summary of Findings:
- No duplicate values found
- No null values found
- Age values fall within a realistic range
- Consistent customer segmentation

===================================================== */

-- Checking for duplicates
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicates
FROM customers;

-- Checking null Values
SELECT
    SUM(CASE WHEN customer_id  IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN signup_date  IS NULL THEN 1 ELSE 0 END) AS null_signup_date,
    SUM(CASE WHEN country      IS NULL THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN age          IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN gender       IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN loyalty_tier IS NULL THEN 1 ELSE 0 END) AS null_loyalty_tier
FROM Customers;

-- Checking for wrong age values
SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age,
    SUM(CASE WHEN age < 0 OR age > 120 THEN 1 ELSE 0 END) AS invalid_ages
FROM Customers;

-- Checking the categories that we have so we can create filters
SELECT DISTINCT loyalty_tier FROM Customers ORDER BY loyalty_tier;
SELECT DISTINCT gender       FROM Customers ORDER BY gender;
SELECT DISTINCT country      FROM Customers ORDER BY country;


/* =====================================================
TABLE: Products
DATA QUALITY CHECKS

Summary of Findings:
- No duplicate values found
- No null values found
- No unexpected prices
- Consistent product segmentation

===================================================== */

-- Total volume and duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicates
FROM Products;

-- Nulls by column
SELECT
    SUM(CASE WHEN product_id   IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN category     IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN brand        IS NULL THEN 1 ELSE 0 END) AS null_brand,
    SUM(CASE WHEN base_price   IS NULL THEN 1 ELSE 0 END) AS null_base_price,
    SUM(CASE WHEN launch_date  IS NULL THEN 1 ELSE 0 END) AS null_launch_date,
    SUM(CASE WHEN is_premium   IS NULL THEN 1 ELSE 0 END) AS null_is_premium
FROM Products;

-- Unexpected values in base_price
SELECT
    MIN(base_price) AS min_price,
    MAX(base_price) AS max_price,
    AVG(base_price) AS avg_price,
    SUM(CASE WHEN base_price <= 0 THEN 1 ELSE 0 END) AS invalid_prices
FROM Products;

-- Categories of categorical fields
SELECT DISTINCT category   FROM Products ORDER BY category;
SELECT DISTINCT brand      FROM Products ORDER BY brand;
SELECT DISTINCT is_premium FROM Products ORDER BY is_premium;


/* =====================================================
TABLE: Campaigns
DATA QUALITY CHECKS

Summary of Findings:
- No duplicate values found
- No null values found
- No inconsistent dates
- No unexpected values from uplift
- Consistent campaign segmentation

===================================================== */

-- Total volume and duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT campaign_id) AS unique_campaigns,
    COUNT(*) - COUNT(DISTINCT campaign_id) AS duplicates
FROM Campaigns;

-- Nulls by column
SELECT
    SUM(CASE WHEN campaign_id      IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN channel          IS NULL THEN 1 ELSE 0 END) AS null_channel,
    SUM(CASE WHEN objective        IS NULL THEN 1 ELSE 0 END) AS null_objective,
    SUM(CASE WHEN start_date       IS NULL THEN 1 ELSE 0 END) AS null_start_date,
    SUM(CASE WHEN end_date         IS NULL THEN 1 ELSE 0 END) AS null_end_date,
    SUM(CASE WHEN target_segment   IS NULL THEN 1 ELSE 0 END) AS null_target_segment,
    SUM(CASE WHEN expected_uplift  IS NULL THEN 1 ELSE 0 END) AS null_expected_uplift
FROM Campaigns;

-- Inconsistent dates (end_date earlier than start_date)
SELECT COUNT(*) AS campaigns_with_invalid_date
FROM Campaigns
WHERE end_date < start_date;

-- Unexpected expected_uplift values
SELECT
    MIN(expected_uplift) AS min_uplift,
    MAX(expected_uplift) AS max_uplift,
    AVG(expected_uplift) AS avg_uplift,
    SUM(CASE WHEN expected_uplift < 0 THEN 1 ELSE 0 END) AS negative_uplift
FROM Campaigns;

-- Categories of categorical fields
SELECT DISTINCT channel          FROM Campaigns ORDER BY channel;
SELECT DISTINCT objective        FROM Campaigns ORDER BY objective;
SELECT DISTINCT target_segment   FROM Campaigns ORDER BY target_segment;


/* =====================================================
TABLE: Events
DATA QUALITY CHECKS

Summary of Findings:
- No duplicate values found
- 200371 null product_ids found
- 40300 null device_types found
- Null value in device_type event segmentation
- Consistent dates
- No events without customers
- 1819374 events without product_id

===================================================== */

-- Total volume and duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) - COUNT(DISTINCT event_id) AS duplicates
FROM Events;

-- Nulls by column
SELECT
    SUM(CASE WHEN event_id       IS NULL THEN 1 ELSE 0 END) AS null_event_id,
    SUM(CASE WHEN timestamp      IS NULL THEN 1 ELSE 0 END) AS null_timestamp,
    SUM(CASE WHEN customer_id    IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN session_id     IS NULL THEN 1 ELSE 0 END) AS null_session_id,
    SUM(CASE WHEN event_type     IS NULL THEN 1 ELSE 0 END) AS null_event_type,
    SUM(CASE WHEN product_id     IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN device_type    IS NULL THEN 1 ELSE 0 END) AS null_device_type,
    SUM(CASE WHEN traffic_source IS NULL THEN 1 ELSE 0 END) AS null_traffic_source,
    SUM(CASE WHEN campaign_id    IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN page_category  IS NULL THEN 1 ELSE 0 END) AS null_page_category
FROM Events;

-- Categories of categorical fields
SELECT DISTINCT event_type     FROM Events ORDER BY event_type;
SELECT DISTINCT device_type    FROM Events ORDER BY device_type;
SELECT DISTINCT traffic_source FROM Events ORDER BY traffic_source;
SELECT DISTINCT page_category  FROM Events ORDER BY page_category;

-- Event date range
SELECT
    MIN(timestamp) AS oldest_event,
    MAX(timestamp) AS most_recent_event
FROM Events;

-- Orphan records — events without valid customer
SELECT COUNT(*) AS events_without_customer
FROM Events e
LEFT JOIN Customers c ON e.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orphan records — events without valid product
SELECT COUNT(*) AS events_without_product
FROM Events e
LEFT JOIN Products p ON e.product_id = p.product_id
WHERE p.product_id IS NULL;


/* =====================================================
TABLE: Transactions
DATA QUALITY CHECKS

Summary of Findings:
- No duplicate values found
- 10449 null product_ids found
- 10449 null gross_revenue found
- Negative values for gross_revenue represent refunds
- Consistent dates
- No events without customers
- 10449 transactions without product_id
- Consistent refund_flag verification

===================================================== */

-- Total volume and duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS unique_transactions,
    COUNT(*) - COUNT(DISTINCT transaction_id) AS duplicates
FROM Transactions;

--Nulls by column

SELECT
    SUM(CASE WHEN transaction_id    IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN timestamp         IS NULL THEN 1 ELSE 0 END) AS null_timestamp,
    SUM(CASE WHEN customer_id       IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id        IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN quantity          IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN discount_applied  IS NULL THEN 1 ELSE 0 END) AS null_discount_applied,
    SUM(CASE WHEN gross_revenue     IS NULL THEN 1 ELSE 0 END) AS null_gross_revenue,
    SUM(CASE WHEN campaign_id       IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN refund_flag       IS NULL THEN 1 ELSE 0 END) AS null_refund_flag
FROM Transactions;

--Validate transaction value distributions

SELECT
    MIN(quantity)         AS min_quantity,
    MAX(quantity)         AS max_quantity,
    MIN(gross_revenue)    AS min_revenue,
    MAX(gross_revenue)    AS max_revenue,
    MIN(discount_applied) AS min_discount,
    MAX(discount_applied) AS max_discount,
    SUM(CASE WHEN quantity <= 0       THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN gross_revenue <= 0  THEN 1 ELSE 0 END) AS invalid_revenue,
    SUM(CASE WHEN discount_applied < 0 THEN 1 ELSE 0 END) AS invalid_discount
FROM Transactions;

-- Transaction date range
SELECT
    MIN(timestamp) AS oldest_transaction,
    MAX(timestamp) AS most_recent_transaction
FROM Transactions;

-- Orphan records — transactions without valid customer
SELECT COUNT(*) AS transactions_without_customer
FROM Transactions t
LEFT JOIN Customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orphan records — transactions without valid product
SELECT COUNT(*) AS transactions_without_product
FROM Transactions t
LEFT JOIN Products p ON t.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Refund flag consistency
SELECT DISTINCT refund_flag FROM Transactions ORDER BY refund_flag;



-- Check which event_types do not have an associated product
SELECT 
    event_type,
    COUNT(*) AS total_events,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS without_product,
    ROUND(
        100.0 * SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS pct_without_product
FROM Events
GROUP BY event_type
ORDER BY without_product DESC;

-- Check which page_categories concentrate the orphan records
SELECT 
    page_category,
    COUNT(*) AS total_events,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS without_product
FROM Events
GROUP BY page_category
ORDER BY without_product DESC;

-- Check if nulls in device_type follow any pattern
SELECT TOP 10
    event_type,
    traffic_source,
    COUNT(*) AS total
FROM Events
WHERE device_type IS NULL
GROUP BY event_type, traffic_source
ORDER BY total DESC;


-- 2000000 total events
-- 1799629 events with product_id
-- 200371 events without product_id

-- 103127 total transactions
-- 92678 transactions with product_id
-- 10449 transactions without product_id

SELECT
COUNT(*)
FROM transactions
WHERE refund_flag = 0 AND product_id IS NOT NULL