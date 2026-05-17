-- Churn Risk Scoring
-- Identifies users by how long since their last order
WITH last_activity AS (
    SELECT
        customer_unique_id,
        last_order_date,
        frequency,
        monetary
    FROM wh_rfm_scores
    WHERE frequency >= 1
)
SELECT
    customer_unique_id,
    last_order_date,
    frequency,
    monetary,
    ('2018-10-01'::DATE - last_order_date::DATE) AS days_since_last_order,
    CASE
        WHEN ('2018-10-01'::DATE - last_order_date::DATE) > 180 THEN 'High Risk'
        WHEN ('2018-10-01'::DATE - last_order_date::DATE) > 90  THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk
FROM last_activity
ORDER BY days_since_last_order DESC;
