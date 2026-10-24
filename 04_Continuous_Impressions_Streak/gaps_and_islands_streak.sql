WITH combined_data AS (
    SELECT 
        ad_date,
        adset_name
    FROM google_ads_basic_daily
    WHERE impressions > 0
    UNION 
    SELECT 
        fbd.ad_date,
        fa.adset_name
    FROM facebook_ads_basic_daily fbd
    LEFT JOIN facebook_adset fa ON fbd.adset_id = fa.adset_id
    WHERE fbd.impressions > 0
),
ranked_data AS (
    SELECT 
        ad_date,
        adset_name,
        ad_date - CAST(ROW_NUMBER() OVER(PARTITION BY adset_name ORDER BY ad_date) AS INT) AS group_anchor
    FROM combined_data
),
streak_groups AS (
    SELECT 
        adset_name,
        MIN(ad_date) AS streak_start,
        MAX(ad_date) AS streak_end,
        (MAX(ad_date) - MIN(ad_date)) + 1 AS streak_length
    FROM ranked_data
    GROUP BY adset_name, group_anchor
)
SELECT 
    adset_name,
    streak_start,
    streak_end,
    streak_length
FROM streak_groups
ORDER BY streak_length DESC
LIMIT 1;
