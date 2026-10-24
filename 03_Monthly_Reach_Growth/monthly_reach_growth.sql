WITH campaign_reach AS (
    SELECT 
        f.ad_date, 
        c.campaign_name, 
        CAST(f.reach AS INT) AS reach 
    FROM public.facebook_ads_basic_daily f
    JOIN public.facebook_campaign c ON f.campaign_id = c.campaign_id
    UNION ALL
    SELECT 
        ad_date, 
        campaign_name, 
        CAST(reach AS INT) AS reach 
    FROM public.google_ads_basic_daily
),
monthly_totals AS (
    SELECT 
        DATE_TRUNC('month', ad_date)::DATE AS ay,
        campaign_name,
        SUM(reach) AS total_reach
    FROM campaign_reach
    GROUP BY DATE_TRUNC('month', ad_date), campaign_name
),
reach_diff AS (
    SELECT 
        ay,
        campaign_name,
        total_reach,
        LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY ay) AS last_month_reach,
        total_reach - LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY ay) AS reach_growth
    FROM monthly_totals
)
SELECT 
    ay,
    campaign_name,
    total_reach AS this_month_reach,
    last_month_reach,
    reach_growth
FROM reach_diff
WHERE reach_growth IS NOT NULL
ORDER BY reach_growth DESC
LIMIT 1;
