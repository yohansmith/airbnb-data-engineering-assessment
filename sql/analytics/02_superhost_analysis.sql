SELECT 
    h.superhost_status,
    COUNT(f.listing_id) as listing_count,
    ROUND(AVG(f.price), 2) as avg_price,
    ROUND(AVG(f.review_scores_rating), 2) as avg_rating
FROM fact_listings f
JOIN dim_host h ON f.host_id = h.host_id
WHERE f.is_active = TRUE
GROUP BY h.superhost_status
ORDER BY avg_rating DESC NULLS LAST;