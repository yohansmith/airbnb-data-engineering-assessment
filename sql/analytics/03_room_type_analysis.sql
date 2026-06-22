SELECT 
    p.room_type,
    p.property_category,
    COUNT(f.listing_id) as listing_count,
    ROUND(AVG(f.price), 2) as avg_price,
    ROUND(AVG(f.review_scores_rating), 2) as avg_rating
FROM fact_listings f
JOIN dim_property p ON f.property_id = p.property_id
WHERE f.price IS NOT NULL AND f.price > 0
GROUP BY p.room_type, p.property_category
ORDER BY avg_price DESC;