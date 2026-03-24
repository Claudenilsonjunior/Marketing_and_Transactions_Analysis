USE Marketing_Transactions

-- ── 1. REVENUE & PROFITABILITY ────────────────────────────────────────────


-- North Star metric: net revenue per active customer
-- Baseline number that every strategic decision should move
SELECT
    ROUND(SUM(gross_revenue_clean), 2) AS net_revenue,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(SUM(gross_revenue_clean) / COUNT(DISTINCT customer_id), 2) AS revenue_per_active_customer
FROM vw_transactions_clean
WHERE refund_flag = 0;

-- Gross revenue vs refunds: understanding true revenue leakage
SELECT
    SUM(gross_revenue_clean) AS gross_revenue,
    SUM(CASE WHEN refund_flag = 1 THEN gross_revenue_clean ELSE 0 END) AS total_refunded,
    COUNT(CASE WHEN refund_flag = 1 THEN 1 END) AS total_refund_transactions,
    ROUND(100.0 * SUM(CASE WHEN refund_flag = 1 THEN gross_revenue_clean ELSE 0 END) / SUM(CASE WHEN refund_flag = 0 THEN gross_revenue_clean ELSE 0 END), 2) AS refund_revenue_pct
FROM vw_transactions_clean;


-- Revenue concentration: how much do the top 5% of transactions contribute?
-- EDA showed p95 at R$25,434 vs median of R$6,079
WITH transaction_percentiles AS (
    SELECT
        transaction_id,
        gross_revenue_clean,
        NTILE(20) OVER (ORDER BY gross_revenue_clean) AS revenue_tile
    FROM vw_transactions_clean
    WHERE refund_flag = 0
)
SELECT
    CASE WHEN revenue_tile = 20 THEN 'Top 5%' ELSE 'Bottom 95%' END AS segment,
    COUNT(*) AS total_transactions,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue,
    ROUND(100.0 * SUM(gross_revenue_clean) / SUM(SUM(gross_revenue_clean)) OVER(), 2) AS pct_of_revenue
FROM transaction_percentiles
GROUP BY CASE WHEN revenue_tile = 20 THEN 'Top 5%' ELSE 'Bottom 95%' END;


-- Monthly revenue growth rate: is the business growing?
WITH monthly_revenue AS (
    SELECT
        FORMAT(timestamp, 'yyyy-MM')  AS month,
        SUM(gross_revenue_clean) AS gross_revenue_clean
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY FORMAT(timestamp, 'yyyy-MM')
),
revenue_with_lag AS (
    SELECT
        month,
        gross_revenue_clean,
        LAG(gross_revenue_clean) OVER (ORDER BY month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(gross_revenue_clean, 2) AS gross_revenue_clean,
    ROUND(prev_month_revenue, 2) AS prev_month_revenue,
    ROUND(100.0 * (gross_revenue_clean - prev_month_revenue) / NULLIF(prev_month_revenue, 0), 2) AS mom_growth_pct
FROM revenue_with_lag
ORDER BY month;


-- Discount impact on revenue: are discounts eroding margin without adding volume?
SELECT
    CASE WHEN discount_applied > 0 THEN 'Discounted' ELSE 'Full Price' END AS price_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(gross_revenue_clean), 2) AS avg_order_value,
    ROUND(AVG(discount_applied), 2) AS avg_discount,
    ROUND(SUM(gross_revenue_clean), 2) AS total_revenue,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_transactions
FROM vw_transactions_clean
WHERE refund_flag = 0
GROUP BY CASE WHEN discount_applied > 0 THEN 'Discounted' ELSE 'Full Price' END;



-- ── 2. RETENTION & LOYALTY ────────────────────────────────────────────────


-- Customer retention rate: what % of customers return after first purchase?
-- EDA flagged 61.7% single-purchase rate as the biggest business risk
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(timestamp) AS first_purchase_date
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
),
returning_customers AS (
    SELECT
        t.customer_id,
        COUNT(*) AS total_purchases
    FROM vw_transactions_clean t
    JOIN first_purchase fp ON t.customer_id = fp.customer_id
    WHERE t.refund_flag = 0
    GROUP BY t.customer_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_purchases = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
    SUM(CASE WHEN total_purchases > 1 THEN 1 ELSE 0 END) AS returning_buyers,
    ROUND(100.0 * SUM(CASE WHEN total_purchases > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_rate_pct
FROM returning_customers;


-- Time between first and second purchase for returning customers
-- Critical window to identify when re-engagement campaigns should fire
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
),
aggregates AS (
    SELECT
        ROUND(AVG(CAST(days_to_second_purchase AS FLOAT)), 1) AS avg_days,
        MIN(days_to_second_purchase)                          AS min_days,
        MAX(days_to_second_purchase)                          AS max_days
    FROM first_second
),
median_calc AS (
    SELECT DISTINCT
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY days_to_second_purchase) OVER(), 1)    AS median_days
    FROM first_second
)
SELECT
    a.avg_days,
    a.min_days,
    a.max_days,
    m.median_days
FROM aggregates a
CROSS JOIN median_calc m;


-- Revenue contribution by customer purchase frequency segment
-- Do returning customers generate disproportionate revenue?
WITH customer_purchases AS (
    SELECT
        customer_id,
        COUNT(*) AS total_purchases,
        SUM(gross_revenue_clean) AS total_revenue
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
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER(), 2) AS pct_of_total_revenue
FROM customer_purchases
GROUP BY
    CASE
        WHEN total_purchases = 1 THEN '1 purchase'
        WHEN total_purchases BETWEEN 2 AND 3 THEN '2-3 purchases'
        WHEN total_purchases BETWEEN 4 AND 5 THEN '4-5 purchases'
        ELSE '6+ purchases'
    END
ORDER BY total_customers DESC;


-- Loyalty tier vs actual retention: does tier predict returning behavior?
WITH customer_purchases AS (
    SELECT
        customer_id,
        COUNT(*) AS total_purchases
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
)
SELECT
    c.loyalty_tier,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN cp.total_purchases > 1 THEN 1 ELSE 0 END) AS returning_customers,
    ROUND(100.0 * SUM(CASE WHEN cp.total_purchases > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_rate_pct,
    ROUND(AVG(CAST(cp.total_purchases AS FLOAT)), 2) AS avg_purchases
FROM vw_customers_clean c
JOIN customer_purchases cp ON c.customer_id = cp.customer_id
GROUP BY c.loyalty_tier
ORDER BY retention_rate_pct DESC;


-- ── 3. CAMPAIGN & CHANNEL PERFORMANCE ────────────────────────────────────


-- Net revenue and refund rate by campaign channel
-- Which channel drives the most valuable and reliable transactions?
SELECT
    c.channel,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    ROUND(SUM(CASE WHEN refund_flag = 0 THEN gross_revenue_clean ELSE 0 END), 2) AS net_revenue,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value,
    ROUND(100.0 * SUM(CAST(t.refund_flag AS INT)) / COUNT(*), 2) AS refund_rate_pct
FROM vw_transactions_clean t
JOIN vw_campaigns_clean c ON t.campaign_id = c.campaign_id
GROUP BY c.channel
ORDER BY net_revenue DESC;


-- Expected uplift vs real conversion rate per campaign
-- Validates whether the probabilistic model matches actual outcomes
WITH campaign_conversion AS (
    SELECT
        campaign_id,
        COUNT(DISTINCT customer_id) AS exposed_customers,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) AS converted_customers
    FROM vw_events_clean
    GROUP BY campaign_id
)
SELECT
    camp.campaign_id,
    camp.channel,
    camp.objective,
    camp.expected_uplift,
    ROUND(100.0 * cc.converted_customers / NULLIF(cc.exposed_customers, 0), 2) AS actual_conversion_pct,
    ROUND((100.0 * cc.converted_customers / NULLIF(cc.exposed_customers, 0)) - (camp.expected_uplift * 100), 2) AS uplift_gap
FROM vw_campaigns_clean camp
JOIN campaign_conversion cc ON camp.campaign_id = cc.campaign_id
ORDER BY uplift_gap DESC;


-- Correcting scale: expected_uplift is already in percentage points
WITH campaign_conversion AS (
    SELECT
        campaign_id,
        COUNT(DISTINCT customer_id) AS exposed_customers,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) AS converted_customers
    FROM vw_events_clean
    GROUP BY campaign_id
)
SELECT
    camp.campaign_id,
    camp.channel,
    camp.objective,
    camp.expected_uplift AS expected_uplift_pct,
    ROUND(100.0 * cc.converted_customers / NULLIF(cc.exposed_customers, 0), 2) AS actual_conversion_pct,
    ROUND(ROUND(100.0 * cc.converted_customers / NULLIF(cc.exposed_customers, 0), 2) - camp.expected_uplift, 2) AS uplift_gap,
    cc.exposed_customers,
    cc.converted_customers
FROM vw_campaigns_clean camp
JOIN campaign_conversion cc ON camp.campaign_id = cc.campaign_id
ORDER BY actual_conversion_pct DESC;


-- Campaign objective vs revenue performance
-- Which campaign objective (awareness, conversion, retention) drives most revenue?
SELECT
    c.objective,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    ROUND(SUM(t.gross_revenue_clean), 2) AS gross_revenue_clean,
    ROUND(AVG(t.gross_revenue_clean), 2) AS avg_order_value,
    COUNT(DISTINCT t.customer_id) AS unique_customers
FROM vw_transactions_clean t
JOIN vw_campaigns_clean c ON t.campaign_id = c.campaign_id
WHERE t.refund_flag = 0
GROUP BY c.objective
ORDER BY gross_revenue_clean DESC;


-- Exposed vs non-exposed customers: does campaign exposure drive more purchases?
WITH exposed AS (
    SELECT DISTINCT customer_id
    FROM vw_events_clean
    WHERE campaign_id IS NOT NULL
),
customer_revenue AS (
    SELECT
        t.customer_id,
        SUM(t.gross_revenue_clean) AS total_revenue,
        COUNT(*) AS total_purchases
    FROM vw_transactions_clean t
    WHERE t.refund_flag = 0
    GROUP BY t.customer_id
)
SELECT
    CASE WHEN e.customer_id IS NOT NULL
         THEN 'Exposed' 
		 ELSE 'Not Exposed' END AS campaign_exposure,
    COUNT(*) AS total_customers,
    ROUND(AVG(cr.total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(AVG(CAST(cr.total_purchases AS FLOAT)), 2) AS avg_purchases_per_customer
FROM customer_revenue cr
LEFT JOIN exposed e ON cr.customer_id = e.customer_id
GROUP BY CASE WHEN e.customer_id IS NOT NULL THEN 'Exposed' 
ELSE 'Not Exposed' END;

-- ── 4. PRODUCT PERFORMANCE ────────────────────────────────────────────────


-- Revenue and refund rate by category
-- Identifies which categories drive revenue and which have quality issues
SELECT
    p.category,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS net_revenue,
    ROUND(AVG(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS avg_order_value,
    ROUND(100.0 * SUM(CAST(t.refund_flag AS INT)) / COUNT(*), 2) AS refund_rate_pct
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY net_revenue DESC;


-- Top 10 products by net revenue
SELECT TOP 10
    p.product_id,
    p.category,
    p.brand,
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END AS product_type,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS net_revenue,
    ROUND(AVG(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS avg_order_value
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
WHERE t.refund_flag = 0
GROUP BY p.product_id, p.category, p.brand, p.is_premium
ORDER BY net_revenue DESC;


-- Premium vs standard performance: volume nearly equal but AOV 3.4x higher
-- Refund rates nearly identical — premium products carry no additional return risk
SELECT
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END AS product_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS net_revenue,
    ROUND(AVG(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS avg_order_value,
    ROUND(100.0 * SUM(CAST(t.refund_flag AS INT)) / COUNT(*), 2) AS refund_rate_pct
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
GROUP BY p.is_premium
ORDER BY net_revenue DESC;


-- Category performance by premium tier
-- Identifies which categories benefit most from premium positioning
SELECT
    p.category,
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END AS product_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS net_revenue,
    ROUND(AVG(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue_clean ELSE 0 END), 2) AS avg_order_value
FROM vw_transactions_clean t
JOIN vw_products_clean p ON t.product_id = p.product_id
WHERE t.refund_flag = 0
GROUP BY p.category, p.is_premium
ORDER BY p.category, product_type;


-- ── 5. CUSTOMER SEGMENTATION ──────────────────────────────────────────────


-- RFM segmentation: Recency, Frequency, Monetary
-- Foundation for targeted retention and upsell campaigns
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(timestamp), '2023-12-31') AS recency_days,
        COUNT(*)                                     AS frequency,
        ROUND(SUM(CASE WHEN refund_flag = 0 THEN gross_revenue_clean ELSE 0 END), 2)           AS monetary
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
        -- Recency: score alto para quem comprou RECENTEMENTE (menos dias)
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        -- Frequency: score alto para quem comprou MAIS vezes
        NTILE(4) OVER (ORDER BY frequency ASC)    AS f_score,
        -- Monetary: score alto para quem gastou MAIS
        NTILE(4) OVER (ORDER BY monetary ASC)     AS m_score
    FROM rfm_base
),
rfm_segments AS (
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
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*)                                                     AS total_customers,
    ROUND(SUM(monetary), 2)                                      AS total_revenue,
    ROUND(AVG(monetary), 2)                                      AS avg_revenue_per_customer,
    ROUND(AVG(CAST(recency_days AS FLOAT)), 0)                   AS avg_recency_days,
    ROUND(AVG(CAST(frequency AS FLOAT)), 2)                      AS avg_frequency,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER(), 2) AS pct_of_revenue
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY total_revenue DESC;


-- RFM segment summary: size and revenue contribution of each segment
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, MAX(timestamp), '2023-12-31') AS recency_days,
        COUNT(*) AS frequency,
        ROUND(SUM(CASE WHEN refund_flag = 0 THEN gross_revenue_clean ELSE 0 END), 2) AS monetary
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
        NTILE(4) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC)   AS f_score,
        NTILE(4) OVER (ORDER BY monetary DESC)    AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        monetary,
        CASE
            WHEN r_score + f_score + m_score >= 10 THEN 'Champions'
            WHEN r_score + f_score + m_score >= 7  THEN 'Loyal'
            WHEN r_score + f_score + m_score >= 5  THEN 'Potential'
            ELSE 'At Risk'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*)                                                    AS total_customers,
    ROUND(SUM(monetary), 2)                                     AS total_revenue,
    ROUND(AVG(monetary), 2)                                     AS avg_revenue_per_customer,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER(), 2) AS pct_of_revenue
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY total_revenue DESC;


-- High value customers: top 10% by revenue
-- Profile of the most important customers for retention focus
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(CASE WHEN refund_flag = 0 THEN gross_revenue_clean ELSE 0 END) AS total_revenue,
        COUNT(*) AS total_purchases,
        MIN(timestamp) AS first_purchase,
        MAX(timestamp) AS last_purchase
    FROM vw_transactions_clean
    WHERE refund_flag = 0
    GROUP BY customer_id
)
SELECT TOP 10
    cr.customer_id,
    c.country,
    c.age,
    c.loyalty_tier,
    cr.total_purchases,
    ROUND(cr.total_revenue, 2) AS total_revenue,
    DATEDIFF(DAY, cr.first_purchase, cr.last_purchase) AS customer_lifespan_days
FROM customer_revenue cr
JOIN vw_customers_clean c ON cr.customer_id = c.customer_id
ORDER BY total_revenue DESC;


-- ── 6. FUNNEL & CONVERSION ────────────────────────────────────────────────


-- Full conversion funnel using customer_id as unit of analysis
-- session_id discarded — confirmed as shared across customers in EDA
WITH funnel AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'view'
                            THEN customer_id END) AS view_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'click'
                            THEN customer_id END) AS click_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'
                            THEN customer_id END) AS cart_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'
                            THEN customer_id END) AS purchase_stage
    FROM vw_events_clean
)
SELECT
    view_stage,
    click_stage,
    cart_stage,
    purchase_stage,
    ROUND(100.0 * click_stage    / NULLIF(view_stage, 0), 2)  AS view_to_click_pct,
    ROUND(100.0 * cart_stage     / NULLIF(click_stage, 0), 2) AS click_to_cart_pct,
    ROUND(100.0 * purchase_stage / NULLIF(cart_stage, 0), 2)  AS cart_to_purchase_pct,
    ROUND(100.0 * purchase_stage / NULLIF(view_stage, 0), 2)  AS overall_conversion_pct
FROM funnel;


-- Conversion rate by device type
-- Identifies which devices complete the funnel most effectively
SELECT
    device_type,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) AS converted_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) / NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS conversion_rate_pct
FROM vw_events_clean
GROUP BY device_type
ORDER BY conversion_rate_pct DESC;


-- Conversion rate by traffic source
-- Organic vs paid: which source brings customers most likely to buy?
SELECT
    traffic_source,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) AS converted_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) / NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS conversion_rate_pct
FROM vw_events_clean
GROUP BY traffic_source
ORDER BY conversion_rate_pct DESC;


-- Drop-off analysis: which step loses the most customers?
WITH funnel AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'view'
                            THEN customer_id END) AS view_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'click'
                            THEN customer_id END) AS click_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'
                            THEN customer_id END) AS cart_stage,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'
                            THEN customer_id END) AS purchase_stage
    FROM vw_events_clean
)
SELECT
    'view → click'          AS funnel_step,
    view_stage              AS customers_in,
    click_stage             AS customers_out,
    view_stage - click_stage AS dropped,
    ROUND(100.0 * (view_stage - click_stage)
        / NULLIF(view_stage, 0), 2) AS drop_off_pct
FROM funnel
UNION ALL
SELECT
    'click → add_to_cart',
    click_stage,
    cart_stage,
    click_stage - cart_stage,
    ROUND(100.0 * (click_stage - cart_stage)
        / NULLIF(click_stage, 0), 2)
FROM funnel
UNION ALL
SELECT
    'add_to_cart → purchase',
    cart_stage,
    purchase_stage,
    cart_stage - purchase_stage,
    ROUND(100.0 * (cart_stage - purchase_stage)
        / NULLIF(cart_stage, 0), 2)
FROM funnel;

-- Bounce analysis: understanding early exit behavior
SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'bounce'
                        THEN customer_id END)       AS bounced_customers,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'bounce'
                                      THEN customer_id END)
        / NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS bounce_rate_pct
FROM vw_events_clean;


-- Bounce vs conversion: do bounced customers ever come back to purchase?
WITH bounced AS (
    SELECT DISTINCT customer_id
    FROM vw_events_clean
    WHERE event_type = 'bounce'
),
purchased AS (
    SELECT DISTINCT customer_id
    FROM vw_events_clean
    WHERE event_type = 'purchase'
)
SELECT
    COUNT(DISTINCT b.customer_id)                    AS total_bounced,
    COUNT(DISTINCT p.customer_id)                    AS bounced_and_purchased,
    ROUND(100.0 * COUNT(DISTINCT p.customer_id)
        / NULLIF(COUNT(DISTINCT b.customer_id), 0), 2) AS bounce_recovery_rate_pct
FROM bounced b
LEFT JOIN purchased p ON b.customer_id = p.customer_id;

-- Check exact event_type values in the table
SELECT DISTINCT
    event_type,
    COUNT(*) AS total_events
FROM vw_events_clean
GROUP BY event_type
ORDER BY total_events DESC;



-- LTV and repeat purchase rate by signup cohort
SELECT
    FORMAT(c.signup_date, 'yyyy-MM')            AS signup_cohort,
    COUNT(DISTINCT t.customer_id)               AS customers,
    ROUND(SUM(t.gross_revenue_clean)
        / COUNT(DISTINCT t.customer_id), 2)     AS avg_ltv,
    ROUND(AVG(t.gross_revenue_clean), 2)        AS avg_order_value,
    ROUND(COUNT(t.transaction_id) * 1.0
        / COUNT(DISTINCT t.customer_id), 2)     AS avg_purchases_per_customer
FROM vw_transactions_clean t
JOIN vw_customers_clean c ON t.customer_id = c.customer_id
WHERE t.refund_flag = 0
GROUP BY FORMAT(c.signup_date, 'yyyy-MM')
ORDER BY signup_cohort;