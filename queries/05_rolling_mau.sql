-- Rolling 30-Day Active Users
-- Tracks platform growth via moving window of daily active users
WITH daily_actives AS (
    SELECT
        activity_date,
        COUNT(DISTINCT customer_unique_id) AS dau
    FROM wh_daily_user_activity
    GROUP BY activity_date
)
SELECT
    activity_date,
    dau,
    SUM(dau) OVER (
        ORDER BY activity_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d_active_users
FROM daily_actives
ORDER BY activity_date;
