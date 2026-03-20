-- ── 1. STATISTICAL DISTRIBUTIONS ─────────────────────────────────────────


-- Revenue distribution: checking for skewness and outliers
-- Mean vs median gap will indicate if high-value transactions distort averages
WITH aggregates AS (
    SELECT
        COUNT(*) AS total_transactions,
        ROUND(MIN(gross_revenue_clean), 2) AS min_revenue,
        ROUND(MAX(gross_revenue_clean), 2) AS max_revenue,
        ROUND(AVG(gross_revenue_clean), 2) AS avg_revenue,
        ROUND(STDEV(gross_revenue_clean), 2) AS stddev_revenue
    FROM vw_transactions_clean
    WHERE refund_flag = 0
),
percentiles AS (
    SELECT DISTINCT
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p25,
        ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p50_median,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p75,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY gross_revenue_clean) OVER(), 2) AS p95
    FROM vw_transactions_clean
    WHERE refund_flag = 0
)
SELECT
*
FROM aggregates a
CROSS JOIN percentiles p;


-- Quantity per transaction: most purchases are single-item
-- High concentration at qty=1 suggests bundle/cross-sell opportunity
SELECT
    quantity,
    COUNT(*) AS total_transactions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY quantity
ORDER BY quantity;


-- Base price distribution by category
-- Electronics shows highest avg price and highest variance — mixed SKU range
SELECT
    category,
    ROUND(MIN(base_price), 2) AS min_price,
    ROUND(MAX(base_price), 2) AS max_price,
    ROUND(AVG(base_price), 2) AS avg_price,
    ROUND(STDEV(base_price), 2) AS stddev_price,
    COUNT(*) AS total_products
FROM vw_products_clean
GROUP BY category
ORDER BY avg_price DESC;


-- ── 2. TEMPORAL PATTERNS ──────────────────────────────────────────────────


-- Monthly revenue and volume: Nov/Dec consistently ~25-30% above average
-- AOV remains stable year-round — seasonality affects frequency, not spend per order
SELECT
    FORMAT(timestamp, 'yyyy-MM') AS month,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id)  AS unique_customers,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY FORMAT(timestamp, 'yyyy-MM')
ORDER BY month;


-- Transactions by weekday: weekend effect confirmed (~11% above weekdays)
-- AOV flat across all days — timing affects volume only
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


-- Hourly event activity: three distinct engagement waves
-- Peak at 19h is the strongest — best window for campaign delivery
SELECT
    DATEPART(HOUR, timestamp) AS hour_of_day,
    COUNT(*) AS total_events,
    COUNT(DISTINCT session_id) AS total_sessions
FROM vw_events_clean
GROUP BY DATEPART(HOUR, timestamp)
ORDER BY hour_of_day;


-- Daily revenue summary statistics
-- Used to detect anomalies and outlier days
WITH daily_revenue AS (
    SELECT
        CAST(timestamp AS DATE) AS date,
        SUM(gross_revenue_clean) AS daily_revenue
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY CAST(timestamp AS DATE)
)
SELECT
    ROUND(MIN(daily_revenue), 2) AS min_daily_revenue,
    ROUND(MAX(daily_revenue), 2) AS max_daily_revenue,
    ROUND(AVG(daily_revenue), 2) AS avg_daily_revenue,
    ROUND(STDEV(daily_revenue), 2) AS stddev_daily_revenue
FROM daily_revenue;


-- ── 3. SESSION & CUSTOMER BEHAVIOR ────────────────────────────────────────


-- Session length distribution: avg 3 events, journeys are short and direct
-- 16% single-event sessions likely represent bounces
WITH session_events AS (
    SELECT
        session_id,
        COUNT(*) AS events_per_session
    FROM vw_events_clean
    GROUP BY session_id
)
SELECT
    ROUND(AVG(CAST(events_per_session AS FLOAT)), 2) AS avg_events,
    MIN(events_per_session) AS min_events,
    MAX(events_per_session) AS max_events,
    ROUND(STDEV(CAST(events_per_session AS FLOAT)), 2) AS stddev_events
FROM session_events;


-- Events per session breakdown
-- 62% of sessions have 3 or fewer events — users decide quickly
WITH session_events AS (
    SELECT
        session_id,
        COUNT(*) AS events_per_session
    FROM vw_events_clean
    GROUP BY session_id
)
SELECT
    events_per_session,
    COUNT(*) AS total_sessions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM session_events
GROUP BY events_per_session
ORDER BY events_per_session;


-- Purchase recurrence: 61.7% of customers bought only once
-- Critical retention gap — the business relies on constant new acquisition
WITH customer_purchases AS (
    SELECT
        customer_id,
        COUNT(*) AS total_purchases
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_purchases = 1 THEN '1 purchase'
        WHEN total_purchases BETWEEN 2 AND 3 THEN '2-3 purchases'
        WHEN total_purchases BETWEEN 4 AND 5 THEN '4-5 purchases'
        ELSE '6+ purchases'
    END AS purchase_segment,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM customer_purchases
GROUP BY
    CASE
        WHEN total_purchases = 1 THEN '1 purchase'
        WHEN total_purchases BETWEEN 2 AND 3 THEN '2-3 purchases'
        WHEN total_purchases BETWEEN 4 AND 5 THEN '4-5 purchases'
        ELSE '6+ purchases'
    END
ORDER BY total_customers DESC;


-- session_id is shared across customers — not a reliable user-level identifier
-- All funnel analyses will use customer_id as the unit of analysis instead
SELECT
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT CONCAT(session_id, customer_id)) AS unique_combinations
FROM vw_events_clean;


-- ── 4. CORRELATIONS ───────────────────────────────────────────────────────


-- Discount vs AOV: discount rate does not reliably increase order value
-- 5% discount has nearly the same AOV as no discount (8,820 vs 8,838)
SELECT
    ROUND(discount_applied, 1) AS discount_band,
    COUNT(*) AS total_transactions,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY ROUND(discount_applied, 1)
ORDER BY discount_band;


-- Loyalty tier vs purchase behavior
-- AOV varies only R$153 across all tiers — tier does not drive spend
-- Frequency is low across the board (max 1.71 purchases/customer)
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


-- Age group vs revenue: AOV flat across all ages (R$156 spread)
-- Revenue difference is driven by customer volume, not individual behavior
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


-- Premium vs standard: nearly equal transaction volume, 3.4x AOV gap
-- Refund rate virtually identical (2.98% vs 2.86%) — no quality signal
SELECT
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END AS product_type,
    COUNT(*) AS total_transactions,
    SUM(CAST(t.refund_flag AS INT)) AS total_refunds,
    ROUND(100.0 * SUM(CAST(t.refund_flag AS INT)) / COUNT(*), 2) AS refund_rate_pct,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
GROUP BY p.is_premium;


-- ── 5. CUSTOMER ACQUISITION ───────────────────────────────────────────────


-- Monthly new customer acquisition: stable ~2,800/month with no growth trend
-- Contrast with 61.7% single-purchase rate reveals an acquisition-dependent model
SELECT
    FORMAT(signup_date, 'yyyy-MM') AS month,
    COUNT(*) AS new_customers
FROM vw_customers_clean
GROUP BY FORMAT(signup_date, 'yyyy-MM')
ORDER BY month;


-- Traffic source distribution: remarkably uniform across all channels (~20% each)
-- Organic leads slightly — zero acquisition cost makes it the most efficient channel
SELECT
    e.traffic_source,
    COUNT(DISTINCT e.customer_id) AS total_customers,
    ROUND(100.0 * COUNT(DISTINCT e.customer_id) / SUM(COUNT(DISTINCT e.customer_id)) OVER(), 2) AS pct
FROM vw_events_clean e
GROUP BY e.traffic_source
ORDER BY total_customers DESC;


-- Gender distribution within loyalty tiers: no meaningful gender skew in any tier
-- Loyalty tier carries no demographic or behavioral signal
SELECT
    c.loyalty_tier,
    c.gender,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY c.loyalty_tier), 2) AS pct_within_tier
FROM vw_customers_clean c
GROUP BY c.loyalty_tier, c.gender
ORDER BY c.loyalty_tier, total_customers DESC;