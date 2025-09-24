

-- Clean Data for future Queries
DROP VIEW IF EXISTS delta_clean;

CREATE VIEW delta_enriched AS
SELECT
  `month`,
  carrier,
  carrier_name,
  airport,
  airport_name,
  
  -- separate airport_name fields
  TRIM(SUBSTRING_INDEX(airport_name, ',', 1)) AS city,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(airport_name, ':', 1), ',', -1)) AS state,
  TRIM(SUBSTRING_INDEX(airport_name, ':', -1)) AS airport_clean,
  
  -- core measures (COALESCE to 0)
  COALESCE(arr_flights, 0)          AS arr_flights,
  COALESCE(arr_del15, 0)            AS arr_del15,
  COALESCE(arr_cancelled, 0)        AS arr_cancelled,
  COALESCE(arr_diverted, 0)         AS arr_diverted,
  COALESCE(arr_delay, 0)            AS arr_delay_minutes_total,
  COALESCE(carrier_ct, 0)           AS carrier_ct,
  COALESCE(weather_ct, 0)           AS weather_ct,
  COALESCE(nas_ct, 0)               AS nas_ct,
  COALESCE(security_ct, 0)          AS security_ct,
  COALESCE(late_aircraft_ct, 0)     AS late_aircraft_ct,
  COALESCE(carrier_delay, 0)        AS carrier_delay_min,
  COALESCE(weather_delay, 0)        AS weather_delay_min,
  COALESCE(nas_delay, 0)            AS nas_delay_min,
  COALESCE(security_delay, 0)       AS security_delay_min,
  COALESCE(late_aircraft_delay, 0)  AS late_aircraft_delay_min,
  
  -- derived KPIs (safe divide)
  CASE WHEN COALESCE(arr_flights,0) > 0
       THEN 1.0 - (COALESCE(arr_del15,0) / NULLIF(arr_flights,0))
       ELSE NULL END                AS on_time_rate,
  CASE WHEN COALESCE(arr_flights,0) > 0
       THEN COALESCE(arr_del15,0) / NULLIF(arr_flights,0)
       ELSE NULL END                AS pct_delayed,
  CASE WHEN COALESCE(arr_flights,0) > 0
       THEN COALESCE(arr_cancelled,0) / NULLIF(arr_flights,0)
       ELSE NULL END                AS pct_cancelled,
  CASE WHEN airport IN ('ATL','DTW','MSP','SLC','JFK','LAX','BOS','SEA')
       THEN 1 ELSE 0 END           AS hub_flag
FROM airline_delay_cause
WHERE carrier = 'DL';


-- ---------------------------------
-- 2 DESCRIPTIVE (OVERALL KPIs)
-- ---------------------------------

-- 2A Overall KPI's
SELECT
  SUM(arr_flights)                                             AS flights,
  SUM(arr_del15)                                               AS delayed_flights,
  ROUND(100.0 * SUM(arr_del15) / NULLIF(SUM(arr_flights),0),2) AS pct_delayed,
  SUM(arr_cancelled)                                           AS cancelled_flights,
  ROUND(100.0 * SUM(arr_cancelled) / NULLIF(SUM(arr_flights),0),2) AS pct_cancelled,
  ROUND(100.0 * (1.0 - SUM(arr_del15) / NULLIF(SUM(arr_flights),0)),2) AS on_time_rate_pct
FROM delta_enriched;

-- -----
-- 2B Delta Flight delays by Cause
-- -----
SELECT
 c.cause,
 ROUND(c.delay_events,2) AS delay_events,
 c.delay_hours,
 ROUND(c.delay_events / NULLIF(t.delayed_flights,0),3) AS pct_events,
 ROUND(c.delay_hours / NULLIF(t.delay_hours_total,0),3) AS pct_hours
FROM (
 SELECT 'Carrier' AS cause,
 SUM(carrier_ct) AS delay_events,
 ROUND(SUM(carrier_delay_min)/60.0,2) AS delay_hours
 FROM delta_enriched
 UNION ALL
 SELECT 'Weather',
 SUM(weather_ct),
 ROUND(SUM(weather_delay_min)/60.0,2)
 FROM delta_enriched
 UNION ALL
 SELECT 'NAS',
 SUM(nas_ct),
 ROUND(SUM(nas_delay_min)/60.0,2)
 FROM delta_enriched
 UNION ALL
 SELECT 'Security',
 SUM(security_ct),
 ROUND(SUM(security_delay_min)/60.0,2)
 FROM delta_enriched
 UNION ALL
 SELECT 'Late_aircraft',
 SUM(late_aircraft_ct),
 ROUND(SUM(late_aircraft_delay_min)/60.0,2)
 FROM delta_enriched
) c
CROSS JOIN (
 SELECT
 SUM(arr_del15) AS delayed_flights,
 ROUND(SUM(arr_delay_minutes_total)/60.0,2) AS delay_hours_total
 FROM delta_enriched
) t
ORDER BY c.delay_hours DESC;



-- -----
-- 2C) Top 10 Airports with highest Delta Flight Delay percentage
-- -----
SELECT
  airport,
  city,
  state,
  SUM(arr_flights)  AS flights,
  SUM(arr_del15)    AS delayed_flights,
  ROUND(100.0 * SUM(arr_del15) / NULLIF(SUM(arr_flights),0), 2) AS pct_delayed
FROM delta_enriched

GROUP BY airport,city,state
ORDER BY pct_delayed DESC
LIMIT 10;

-- =================================
-- 3) COMPARATIVE VIEWS
-- =================================

-- -----
-- 3A) Delta Hub vs Non-Hub
-- -----
SELECT
  CASE WHEN hub_flag=1 THEN 'Hub' ELSE 'Non-Hub' END AS airport_class,
  SUM(arr_flights)  AS flights,
  SUM(arr_del15)    AS delayed_flights,
  ROUND(100.0 * SUM(arr_del15) / NULLIF(SUM(arr_flights),0), 2) AS pct_delayed,
  ROUND(100.0 * SUM(carrier_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_carrier,
  ROUND(100.0 * SUM(weather_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_weather,
  ROUND(100.0 * SUM(nas_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_nas,
  ROUND(100.0 * SUM(security_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_security,
  ROUND(100.0 * SUM(late_aircraft_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_late_aircraft
FROM delta_enriched
GROUP BY airport_class
ORDER BY airport_class;

-- -----
-- 3B) HUB comaprison delays/cancellations
-- -----
SELECT
  airport,
  city,
  state,
  SUM(arr_flights)  AS flights,
  ROUND(100.0 * SUM(arr_del15) / NULLIF(SUM(arr_flights),0), 2) AS pct_delayed,
  ROUND(100.0 * SUM(arr_cancelled) / NULLIF(SUM(arr_flights),0), 2) AS pct_cancelled,
  ROUND(100.0 * SUM(carrier_delay_min)       / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_carrier,
  ROUND(100.0 * SUM(weather_delay_min)       / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_weather,
  ROUND(100.0 * SUM(nas_delay_min)           / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_nas,
  ROUND(100.0 * SUM(late_aircraft_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_late_aircraft
FROM delta_enriched
WHERE hub_flag = 1
GROUP BY airport,city,state
ORDER BY pct_delayed DESC;

-- -----
-- 3C) ATL spotlight (aggregated)
-- -----
SELECT
  'ATL' AS airport,
  SUM(arr_flights)               AS flights,
  SUM(arr_del15)                 AS delayed_flights,
  ROUND(100.0 * SUM(arr_del15) / NULLIF(SUM(arr_flights),0), 2) AS pct_delayed,
  SUM(arr_cancelled)             AS cancelled_flights,
  ROUND(100.0 * SUM(arr_cancelled) / NULLIF(SUM(arr_flights),0), 2) AS pct_cancelled,
  SUM(arr_delay_minutes_total)   AS delay_minutes_total,
  ROUND(100.0 * SUM(carrier_delay_min)       / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_carrier,
  ROUND(100.0 * SUM(weather_delay_min)       / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_weather,
  ROUND(100.0 * SUM(nas_delay_min)           / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_nas,
  ROUND(100.0 * SUM(security_delay_min)      / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_security,
  ROUND(100.0 * SUM(late_aircraft_delay_min) / NULLIF(SUM(arr_delay_minutes_total),0), 2) AS pct_minutes_late_aircraft
FROM delta_enriched
WHERE airport='ATL';

-- =================================
-- 4) TRENDS (MONTHLY)
-- =================================

-- -----
-- 4A) Monthly on-time rate (weighted)
-- -----
SELECT
  `month`,
  ROUND(1.0 - SUM(arr_del15) / NULLIF(SUM(arr_flights),0), 4) AS on_time_rate
FROM delta_enriched
GROUP BY `month`
ORDER BY `month`;

-- -----
-- 4B) Monthly Delay Hours by cause
-- -----
SELECT
  `month`,
  ROUND(SUM(carrier_delay_min)/60,2)      AS carrier_delay_hour,
  ROUND(SUM(weather_delay_min)/60,2)       AS weather_delay_hour,
  ROUND(SUM(nas_delay_min)/60,2)          AS nas_delay_hour,
  ROUND(SUM(security_delay_min)/60,2)      AS security_delay_hour,
  ROUND(SUM(late_aircraft_delay_min)/60,2) AS late_aircraft_delay_hour,
  ROUND(SUM(arr_delay_minutes_total)/60,2) AS delay_hours_total
FROM delta_enriched
GROUP BY `month`
ORDER BY `month`;


