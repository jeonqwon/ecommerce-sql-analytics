-- ============================================
-- WAREHOUSE LAYER: Aggregated tables for
-- dashboard and analysis
-- ============================================

CREATE TABLE wh_user_cohorts AS
WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        COUNT(DISTINCT o.order_id)      AS total_orders,
        SUM(p.payment_value)            AS total_spend
    FROM clean_customers c
    JOIN clean_orders o ON c.customer_id = o.customer_id
    JOIN clean_order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    first_order_date,
    DATE_TRUNC('month', first_order_date) AS cohort_month,
    total_orders,
    ROUND(total_spend::NUMERIC, 2)        AS total_spend,
    CASE
        WHEN total_orders = 1 THEN 'one-time'
        WHEN total_orders BETWEEN 2 AND 4 THEN 'repeat'
        ELSE 'loyal'
    END AS customer_segment
FROM first_orders;

CREATE TABLE wh_monthly_retention AS
WITH user_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM clean_customers c
    JOIN clean_orders o ON c.customer_id = o.customer_id
),
cohorts AS (
    SELECT customer_unique_id, MIN(order_month) AS cohort_month
    FROM user_orders
    GROUP BY customer_unique_id
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        uo.order_month,
        COUNT(DISTINCT uo.customer_unique_id) AS active_users,
        EXTRACT(MONTH FROM AGE(uo.order_month, c.cohort_month)) +
        EXTRACT(YEAR FROM AGE(uo.order_month, c.cohort_month)) * 12 AS months_since_first_order
    FROM user_orders uo
    JOIN cohorts c ON uo.customer_unique_id = c.customer_unique_id
    GROUP BY c.cohort_month, uo.order_month
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.order_month,
    ca.months_since_first_order,
    ca.active_users,
    cs.cohort_size,
    ROUND(100.0 * ca.active_users / cs.cohort_size, 2) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.months_since_first_order;

CREATE TABLE wh_rfm_scores AS
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)         AS last_order_date,
        COUNT(DISTINCT o.order_id)              AS frequency,
        ROUND(SUM(p.payment_value)::NUMERIC, 2) AS monetary
    FROM clean_customers c
    JOIN clean_orders o ON c.customer_id = o.customer_id
    JOIN clean_order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)       AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)        AS m_score
    FROM rfm_base
)
SELECT
    customer_unique_id,
    last_order_date,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'At Risk'
        ELSE 'Lost'
    END AS rfm_segment
FROM rfm_scored;
