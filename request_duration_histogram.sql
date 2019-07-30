SELECT COUNT(*), MIN(request_duration_ms), Q1::INT, MEDIAN::INT, Q3::INT, P95::INT, MAX(request_duration_ms), AVG(request_duration_ms)::INT, SUM(request_duration_ms), left_request
FROM (
        SELECT
                request_duration_ms,
                LEFT(request, 130) left_request,
                PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY LEFT(request, 130)) AS Q1,
                MEDIAN(request_duration_ms) OVER(PARTITION BY LEFT(request, 130)) AS MEDIAN,
                PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY LEFT(request, 130)) AS Q3,
                PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY request_duration_ms) OVER (PARTITION BY LEFT(request, 130)) AS P95
        FROM query_requests
        WHERE
                request_type = 'QUERY'
)x
GROUP BY Q1, MEDIAN, Q3, P95, left_request;
