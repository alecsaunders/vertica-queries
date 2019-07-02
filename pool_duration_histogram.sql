SELECT COUNT(*), MIN(request_duration_ms), Q1::INT, MEDIAN::INT, Q3::INT, P95::INT, MAX(request_duration_ms), AVG(request_duration_ms)::INT, SUM(request_duration_ms), pool_name
FROM (
        SELECT
                request_duration_ms,
                pool_name,
                PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY pool_name) AS Q1,
                MEDIAN(request_duration_ms) OVER(PARTITION BY pool_name) AS MEDIAN,
                PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY pool_name) AS Q3,
                PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY pool_name) AS P95
        FROM query_requests qr
        LEFT JOIN (
                SELECT DISTINCT transaction_id, pool_name
                FROM dc_resource_acquisitions
        ) ra
        ON qr.transaction_id = ra.transaction_id
        WHERE
                pool_name NOT IN ('sysquery')
)x
GROUP BY Q1, MEDIAN, Q3, P95, pool_name;