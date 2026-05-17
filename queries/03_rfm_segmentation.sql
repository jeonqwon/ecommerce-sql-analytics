-- RFM Segment Summary
-- Breaks down user base into Champions, Loyal, At Risk, Lost
SELECT
    rfm_segment,
    COUNT(*)                                                    AS user_count,
    ROUND(AVG(monetary), 2)                                     AS avg_spend,
    ROUND(AVG(frequency), 2)                                    AS avg_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)         AS pct_of_users
FROM wh_rfm_scores
GROUP BY rfm_segment
ORDER BY avg_spend DESC;
