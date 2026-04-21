-- ── ADDITIONAL VIEWS FOR POWER BI ─────────────────────────────────────────


-- RFM segmentation pre-calculated
-- DAX cannot handle NTILE() — easier to bring segmented data ready
CREATE VIEW vw_rfm_segments AS
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(timestamp), '2023-12-31') AS recency_days,
        COUNT(*)                                     AS frequency,
        ROUND(SUM(gross_revenue_clean), 2)           AS monetary
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)    AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)     AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score AS rfm_total,
    CASE
        WHEN r_score + f_score + m_score >= 10 THEN 'Champions'
        WHEN r_score + f_score + m_score >= 7  THEN 'Loyal'
        WHEN r_score + f_score + m_score >= 5  THEN 'Potential'
        ELSE 'At Risk'
    END AS rfm_segment
FROM rfm_scores;


-- Cohort base: each customer's signup cohort and purchase behavior
-- Used for cohort LTV and frequency charts
CREATE VIEW vw_cohort_analysis AS
SELECT
    c.customer_id,
    FORMAT(c.signup_date, 'yyyy-MM')            AS signup_cohort,
    COUNT(t.transaction_id)                     AS total_purchases,
    ROUND(SUM(t.gross_revenue_clean), 2)        AS total_revenue,
    ROUND(AVG(t.gross_revenue_clean), 2)        AS avg_order_value,
    MIN(t.timestamp)                            AS first_purchase_date,
    MAX(t.timestamp)                            AS last_purchase_date
FROM vw_customers_clean c
LEFT JOIN vw_transactions_clean t
    ON c.customer_id = t.customer_id
    AND t.refund_flag = 0
GROUP BY c.customer_id, FORMAT(c.signup_date, 'yyyy-MM');


-- Funnel steps per customer: one row per customer with their deepest funnel stage
-- Avoids complex DAX CALCULATE chains for funnel logic
CREATE VIEW vw_funnel_customers AS
SELECT
    customer_id,
    MAX(CASE WHEN event_type = 'view'         THEN 1 ELSE 0 END) AS reached_view,
    MAX(CASE WHEN event_type = 'click'        THEN 1 ELSE 0 END) AS reached_click,
    MAX(CASE WHEN event_type = 'add_to_cart'  THEN 1 ELSE 0 END) AS reached_cart,
    MAX(CASE WHEN event_type = 'purchase'     THEN 1 ELSE 0 END) AS reached_purchase,
    MAX(CASE WHEN event_type = 'bounce'       THEN 1 ELSE 0 END) AS has_bounce
FROM vw_events_clean
GROUP BY customer_id;


-- Customer summary: one row per customer with key behavioral metrics
-- Avoids repeated aggregation in DAX for customer-level analysis
CREATE VIEW vw_customer_summary AS
WITH purchases AS (
    SELECT
        customer_id,
        COUNT(*)                                    AS total_purchases,
        ROUND(SUM(gross_revenue_clean), 2)          AS total_revenue,
        ROUND(AVG(gross_revenue_clean), 2)          AS avg_order_value,
        MIN(timestamp)                              AS first_purchase_date,
        MAX(timestamp)                              AS last_purchase_date,
        DATEDIFF(DAY, MIN(timestamp), MAX(timestamp)) AS lifespan_days
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.signup_date,
    c.country,
    c.age,
    c.gender,
    c.loyalty_tier,
    CASE
        WHEN c.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END                                             AS age_group,
    COALESCE(p.total_purchases, 0)                  AS total_purchases,
    COALESCE(p.total_revenue, 0)                    AS total_revenue,
    COALESCE(p.avg_order_value, 0)                  AS avg_order_value,
    p.first_purchase_date,
    p.last_purchase_date,
    COALESCE(p.lifespan_days, 0)                    AS lifespan_days,
    CASE WHEN p.total_purchases > 1
         THEN 1 ELSE 0 END                          AS is_returning,
    CASE WHEN p.total_purchases IS NULL
         THEN 1 ELSE 0 END                          AS never_purchased
FROM vw_customers_clean c
LEFT JOIN purchases p ON c.customer_id = p.customer_id;


-- Median days to 2nd purchase metric
CREATE VIEW vw_days_to_second_purchase AS
WITH purchase_sequence AS (
    SELECT
        customer_id,
        timestamp,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY timestamp) AS purchase_rank
    FROM vw_transactions_clean
    WHERE refund_flag = 0
),
first_second AS (
    SELECT
        p1.customer_id,
        DATEDIFF(DAY, p1.timestamp, p2.timestamp) AS days_to_second_purchase
    FROM purchase_sequence p1
    JOIN purchase_sequence p2
        ON p1.customer_id = p2.customer_id
        AND p1.purchase_rank = 1
        AND p2.purchase_rank = 2
)
SELECT
    days_to_second_purchase,
    COUNT(*) AS total_customers
FROM first_second
GROUP BY days_to_second_purchase;
