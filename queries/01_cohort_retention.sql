-- Cohort Retention Matrix
-- Shows what % of each monthly cohort returned to purchase in subsequent months
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM') AS cohort,
    months_since_first_order         AS month_number,
    cohort_size,
    active_users,
    retention_rate
FROM wh_monthly_retention
WHERE months_since_first_order <= 6
ORDER BY cohort_month, months_since_first_order;
