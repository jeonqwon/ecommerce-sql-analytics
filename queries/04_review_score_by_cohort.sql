-- Review Score Trend by Cohort
-- Tracks whether satisfaction changes over time
WITH order_reviews AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        r.review_score,
        uc.cohort_month
    FROM clean_orders o
    JOIN clean_customers c     ON c.customer_id = o.customer_id
    JOIN clean_order_reviews r ON o.order_id = r.order_id
    JOIN wh_user_cohorts uc    ON c.customer_unique_id = uc.customer_unique_id
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM') AS cohort,
    ROUND(AVG(review_score), 2)      AS avg_review_score,
    COUNT(*)                         AS total_reviews
FROM order_reviews
GROUP BY cohort_month
ORDER BY cohort_month;
