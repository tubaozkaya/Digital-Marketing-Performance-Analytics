WITH combined_ads AS (
    SELECT 
        fabd.ad_date,
        'Facebook' AS media_source,
        fabd.spend
    FROM public.facebook_ads_basic_daily fabd
    LEFT JOIN public.facebook_adset fa ON fabd.adset_id = fa.adset_id
    LEFT JOIN public.facebook_campaign fc ON fabd.campaign_id = fc.campaign_id
    UNION ALL
    SELECT 
        gabd.ad_date,
        'Google' AS media_source,
        gabd.spend
    FROM public.google_ads_basic_daily gabd
)
SELECT 
    ad_date,
    media_source,
    ROUND(AVG(spend)::numeric, 2) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM combined_ads
GROUP BY ad_date, media_source
ORDER BY ad_date DESC, media_source;

WITH daily_metrics AS (
    SELECT ad_date, spend, value FROM public.facebook_ads_basic_daily
    UNION ALL
    SELECT ad_date, spend, value FROM public.google_ads_basic_daily
),
daily_totals AS (
    SELECT 
        ad_date,
        SUM(CAST(spend AS NUMERIC)) AS total_spend,
        SUM(CAST(value AS NUMERIC)) AS total_value
    FROM daily_metrics
    GROUP BY ad_date
)
SELECT 
    ad_date,
    ROUND((total_value / NULLIF(total_spend, 0)), 4) AS romi
FROM daily_totals
WHERE total_spend > 0
ORDER BY romi DESC, ad_date DESC
LIMIT 5;
