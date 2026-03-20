USE Marketing_Transactions


/* =====================================================
BLOCK 1 — STATISTICAL DISTRIBUTIONS

Objective:
Analyze distribution of revenue, quantity, and pricing
to understand variability and outliers.

===================================================== */

/* -----------------------------------------------------
ANALYSIS 01
Description: Summary statistics and percentiles for revenue
----------------------------------------------------- */

WITH revenue_stats AS (
    SELECT
        COUNT(*)                        AS total_transactions,
        ROUND(MIN(gross_revenue_clean), 2)    AS min_revenue,
        ROUND(MAX(gross_revenue_clean), 2)    AS max_revenue,
        ROUND(AVG(gross_revenue_clean), 2)    AS avg_revenue,
        ROUND(STDEV(gross_revenue_clean), 2)  AS stddev_revenue
    FROM vw_transactions_clean
    WHERE refund_flag = 0
),
revenue_percentiles AS (
    SELECT DISTINCT
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p25,
        ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS median_p50,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p75,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p95
    FROM vw_transactions_clean
    WHERE refund_flag = 0
)
SELECT *
FROM revenue_stats rs
CROSS JOIN revenue_percentiles rp;

/* -----------------------------------------------------
ANALYSIS 02
Description: Distribution of quantity per transaction
----------------------------------------------------- */

SELECT
    quantity,
    COUNT(*) AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY quantity
ORDER BY quantity;

/* -----------------------------------------------------
ANALYSIS 03
Description: Price distribution by product category
----------------------------------------------------- */

SELECT
    category,
    ROUND(MIN(base_price), 2)   AS min_price,
    ROUND(MAX(base_price), 2)   AS max_price,
    ROUND(AVG(base_price), 2)   AS avg_price,
    ROUND(STDEV(base_price), 2) AS stddev_price,
    COUNT(*)                    AS total_products
FROM vw_products_clean
GROUP BY category
ORDER BY avg_price DESC;

/* =====================================================
BLOCK 2 — TEMPORAL ANALYSIS

Objective:
Identify trends, seasonality, and behavioral patterns over time.

===================================================== */

/* -----------------------------------------------------
ANALYSIS 04
Description: Monthly revenue and transaction trends
----------------------------------------------------- */
SELECT
    FORMAT(timestamp, 'yyyy-MM') AS month,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY FORMAT(timestamp, 'yyyy-MM')
ORDER BY month;

/* -----------------------------------------------------
ANALYSIS 05
Description: Revenue performance by weekday
----------------------------------------------------- */

SELECT
    DATENAME(WEEKDAY, timestamp) AS weekday_name,
    DATEPART(WEEKDAY, timestamp) AS weekday_order,
    COUNT(*) AS total_transactions,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY DATENAME(WEEKDAY, timestamp), DATEPART(WEEKDAY, timestamp)
ORDER BY weekday_order;

/* -----------------------------------------------------
ANALYSIS 06
Description: User activity by hour of day
----------------------------------------------------- */

SELECT
    DATEPART(HOUR, timestamp) AS hour,
    COUNT(*) AS total_events,
    COUNT(DISTINCT session_id) AS total_sessions
FROM vw_events_clean
GROUP BY DATEPART(HOUR, timestamp)
ORDER BY hour;

/* -----------------------------------------------------
ANALYSIS 07
Description: Identify peak and low-performing days
----------------------------------------------------- */

SELECT
    CAST(timestamp AS DATE) AS date,
    COUNT(*) AS total_transactions,
    ROUND(SUM(gross_revenue_clean), 2) AS daily_revenue
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY CAST(timestamp AS DATE)
ORDER BY daily_revenue DESC;


/* =====================================================
BLOCK 3 — SESSION BEHAVIOR

Objective:
Understand user engagement and session patterns.

===================================================== */


/* -----------------------------------------------------
ANALYSIS 08
Description: Average number of events per session
----------------------------------------------------- */

SELECT
    ROUND(AVG(events_per_session), 2) AS avg_events_per_session,
    MIN(events_per_session) AS min_events,
    MAX(events_per_session) AS max_events,
    ROUND(STDEV(events_per_session), 2) AS stddev_events
FROM (
    SELECT
        session_id,
        COUNT(*) AS events_per_session
    FROM vw_events_clean
    GROUP BY session_id
) s;

/* -----------------------------------------------------
ANALYSIS 09
Description: Distribution of events per session
----------------------------------------------------- */

SELECT
    events_per_session,
    COUNT(*) AS total_sessions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT session_id, COUNT(*) AS events_per_session
    FROM vw_events_clean
    GROUP BY session_id
) s
GROUP BY events_per_session
ORDER BY events_per_session;

/* -----------------------------------------------------
ANALYSIS 10
Description: Customer purchase frequency segmentation
----------------------------------------------------- */

SELECT
    CASE
        WHEN total_transactions = 1 THEN '1 purchase'
        WHEN total_transactions BETWEEN 2 AND 3 THEN '2-3 purchases'
        WHEN total_transactions BETWEEN 4 AND 5 THEN '4-5 purchases'
        ELSE '6+ purchases'
    END AS purchase_segment,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT customer_id, COUNT(*) AS total_transactions
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
) t
GROUP BY
    CASE
        WHEN total_transactions = 1 THEN '1 purchase'
        WHEN total_transactions BETWEEN 2 AND 3 THEN '2-3 purchases'
        WHEN total_transactions BETWEEN 4 AND 5 THEN '4-5 purchases'
        ELSE '6+ purchases'
    END
ORDER BY total_customers DESC;


/* =====================================================
BLOCK 4 — CORRELATIONS & RELATIONSHIPS

Objective:
Understand relationships between discounts, customer
segments, and product characteristics.

===================================================== */


/* -----------------------------------------------------
ANALYSIS 12
Description: Impact of discounts on revenue
----------------------------------------------------- */

SELECT
    ROUND(discount_applied, 1) AS discount_band,
    COUNT(*) AS total_transactions,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY ROUND(discount_applied, 1)
ORDER BY discount_band;

/* -----------------------------------------------------
ANALYSIS 13
Description: Loyalty tier vs revenue and frequency
----------------------------------------------------- */

SELECT
    c.loyalty_tier,
    COUNT(DISTINCT t.customer_id) AS total_customers,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value,
    ROUND(1.0 * COUNT(t.transaction_id) / COUNT(DISTINCT t.customer_id), 2) AS transactions_per_customer
FROM vw_transactions_clean t
JOIN vw_customers_clean c ON t.customer_id = c.customer_id
WHERE t.refund_flag = 0
GROUP BY c.loyalty_tier
ORDER BY avg_order_value DESC;

/* -----------------------------------------------------
ANALYSIS 14
Description: Revenue by age group
----------------------------------------------------- */

SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(DISTINCT t.customer_id) AS total_customers,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value,
    ROUND(SUM(t.gross_revenue_clean), 2) AS total_revenue
FROM vw_transactions_clean t
JOIN vw_customers_clean c ON t.customer_id = c.customer_id
WHERE t.refund_flag = 0
GROUP BY
    CASE
        WHEN c.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END
ORDER BY age_group;



/* -----------------------------------------------------
ANALYSIS 15
Description: Refund rate by product type
----------------------------------------------------- */

SELECT
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END AS product_type,
    COUNT(*)  AS total_transactions,
    SUM(CAST(t.refund_flag AS INT)) AS total_refunds,
    ROUND(100.0 * SUM(CAST(t.refund_flag AS INT)) / COUNT(*), 2)  AS refund_rate_pct,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
GROUP BY p.is_premium;


/* =====================================================
BLOCK 5 — CUSTOMER ACQUISITION

Objective:
Understand how customers are acquired and segmented.

===================================================== */


/* -----------------------------------------------------
ANALYSIS 16
Description: Monthly customer acquisition
----------------------------------------------------- */

SELECT
    FORMAT(signup_date, 'yyyy-MM') AS month,
    COUNT(*) AS new_customers
FROM vw_customers_clean
GROUP BY FORMAT(signup_date, 'yyyy-MM')
ORDER BY month;

/* -----------------------------------------------------
ANALYSIS 17
Description: Customer acquisition by traffic source
----------------------------------------------------- */

SELECT
    traffic_source,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / SUM(COUNT(DISTINCT customer_id)) OVER(), 2) AS percentage
FROM vw_events_clean
GROUP BY traffic_source
ORDER BY total_customers DESC;

/* -----------------------------------------------------
ANALYSIS 18
Description: Gender distribution within loyalty tiers
----------------------------------------------------- */

SELECT
    loyalty_tier,
    gender,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY loyalty_tier), 2) AS percentage_within_tier
FROM vw_customers_clean
GROUP BY loyalty_tier, gender
ORDER BY loyalty_tier, total_customers DESC;