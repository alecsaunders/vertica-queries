SELECT AVG(request_duration_ms)::INT, MAX(request_duration_ms), SUM(request_duration_ms), COUNT(*), SUM(CASE WHEN NOT success OR error_count IS NOT NULL THEN 1 ELSE 0 END) error_count, query_type
FROM (
        SELECT
                CASE
                        WHEN request ILIKE 'copy %' THEN 'COPY'
                        WHEN request ILIKE 'delete %' THEN 'DELETE'
                        WHEN REGEXP_ILIKE(regexp_replace(request, '\/\*\+direct\*\/', ' ', 1, 1, 'i'), '.*INSERT INTO\s+\w+\.\w+.*') THEN 'INSERT'
                        WHEN REGEXP_ILIKE(regexp_replace(request, '\/\*\+direct\*\/', ' ', 1, 1, 'i'), '.*UPDATE\s+\w+\.\w+.*') THEN 'UPDATE'
                        WHEN request ILIKE 'truncate %' THEN 'TRUNCATE'
                        WHEN request ILIKE 'merge %' THEN 'MERGE'
                        WHEN request ILIKE 'CREATE %' OR request ILIKE 'DROP %' OR request ILIKE 'ALTER %' THEN 'DDL'
                        WHEN request ILIKE 'SELECT DROP_PARTITION%' THEN 'DROP PARTITION'
                        WHEN request ILIKE 'SET SESSION %' THEN 'SET SESSION'
                        WHEN request ILIKE 'SELECT ANALYZE_STATISTICS%' THEN 'ANALYZE STATS'
                        ELSE 'QUERY'
                END query_type,
                *
        FROM query_requests
) qr
WHERE
        user_name = 'dbadmin'
GROUP BY query_type
ORDER BY query_type;
