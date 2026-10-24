WITH campaign_data AS (
    SELECT 
        f.ad_date, 
        c.campaign_name, 
        CAST(f.value AS NUMERIC) AS value 
    FROM public.facebook_ads_basic_daily f
    JOIN public.facebook_campaign c ON f.campaign_id = c.campaign_id
    UNION ALL  
    SELECT 
        ad_date, 
        campaign_name, 
        CAST(value AS NUMERIC) AS value 
    FROM public.google_ads_basic_daily
),
weekly_campaign_totals AS (
    SELECT 
        DATE_TRUNC('week', ad_date)::DATE AS weekly_beginning,
        campaign_name,
        SUM(value) AS total_value
    FROM campaign_data
    GROUP BY DATE_TRUNC('week', ad_date), campaign_name
)
SELECT 
    weekly_beginning,
    campaign_name,
    ROUND(total_value, 2) AS top_value
FROM weekly_campaign_totals
ORDER BY total_value DESC
LIMIT 1;
