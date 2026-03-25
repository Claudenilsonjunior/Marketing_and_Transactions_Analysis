/* =====================================================
DATA CLEANING LAYER
Purpose: Create standardized analytical views
These views apply the cleaning rules identified
during the Data Quality phase.

All transformations are non-destructive and preserve
the original raw tables.

===================================================== */


/* =====================================================
TABLE: Customers
CLEANING RULES

Actions:
- No transformations required
- Table passed all data quality checks
- View created to standardize analytical layer

===================================================== */

CREATE VIEW vw_customers_clean AS
SELECT
    customer_id,
    signup_date,
    country,
    age,
    gender,
    loyalty_tier
FROM Customers;

/* =====================================================
TABLE: Customers
CLEANING RULES

Actions:
- No transformations required
- Table passed all data quality checks
- View created to standardize analytical layer

===================================================== */

CREATE VIEW vw_products_clean AS
SELECT
    product_id,
    category,
    brand,
    base_price,
    launch_date,
    is_premium
FROM Products;

/* =====================================================
TABLE: Products
CLEANING RULES

Actions:
- No data issues detected
- View created for analytical consistency

===================================================== */

CREATE VIEW vw_campaigns_clean AS
SELECT
    campaign_id,
    channel,
    objective,
    start_date,
    end_date,
    target_segment,
    expected_uplift
FROM Campaigns;

/* =====================================================
TABLE: Events
CLEANING RULES

Rule 1:
Events related to product interaction must contain
a valid product_id.

Affected event types:
- purchase
- add_to_cart

Records violating this rule are excluded.

Rule 2:
Missing device_type values are categorized
as 'Unknown'.

===================================================== */

CREATE VIEW vw_events_clean AS
SELECT
    event_id,
    timestamp,
    customer_id,
    session_id,
    event_type,
    product_id,
    ISNULL(device_type, 'Unknown') AS device_type,
    traffic_source,
    campaign_id,
    page_category
FROM Events
WHERE NOT (
    event_type IN ('purchase', 'add_to_cart')
    AND product_id IS NULL
);


/* =====================================================
TABLE: Transactions
CLEANING RULES

Rule 1:
Transactions must contain a valid product_id.
Records without product_id are excluded.

Rule 2:
Refund transactions often store negative revenue
values in the raw dataset.

For analytical consistency:
- Refund values are converted to positive numbers
- Refund identification is controlled by refund_flag

This allows analysts to easily measure:
- total sales
- total refunds
- net revenue

Implementation:
- gross_revenue keeps the absolute value of the transaction
- refund_flag identifies whether the transaction is a refund

===================================================== */

CREATE VIEW vw_transactions_clean AS
SELECT
    transaction_id,
    timestamp,
    customer_id,
    product_id,
    quantity,
    discount_applied,
	gross_revenue AS gross_revenue_raw,
    CASE 
        WHEN refund_flag = 0 THEN gross_revenue  
        ELSE ABS(gross_revenue)                   
    END AS gross_revenue_clean,
    campaign_id,
    refund_flag
FROM Transactions
WHERE product_id IS NOT NULL;




-- Updating this view to solve a issue with the Power BI Dashboard

ALTER VIEW vw_transactions_clean AS
SELECT
    transaction_id,
    timestamp,
    customer_id,
    product_id,
    quantity,
    discount_applied,
    gross_revenue                               AS gross_revenue_raw,
    CASE
        WHEN refund_flag = 0 THEN gross_revenue
        ELSE ABS(gross_revenue)
    END                                         AS gross_revenue_clean,
    campaign_id,
    CAST(refund_flag AS INT)                    AS refund_flag
FROM Transactions
WHERE product_id IS NOT NULL;