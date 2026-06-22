SELECT 
    loc.neighbourhood,
    COUNT(f.listing_id) as listing_count,
    ROUND(AVG(f.price), 2) as avg_price,
    ROUND(MEDIAN(f.price), 2) as median_price
FROM fact_listings f
JOIN dim_location loc ON f.location_id = loc.location_id
WHERE f.price IS NOT NULL AND f.price > 0
GROUP BY loc.neighbourhood
ORDER BY avg_price DESC;