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
