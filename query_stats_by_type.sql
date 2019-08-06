WITH query_types AS (
        SELECT
                CASE
                    WHEN request_type = 'TRUNCATE' THEN 'TRUNCATE'
                    WHEN request ILIKE 'SHOW %' THEN 'SHOW'
                    WHEN request ILIKE 'copy %' THEN 'COPY'
                    WHEN request_type = 'DDL' THEN
                      CASE
                        WHEN request ILIKE 'CREATE %' THEN 'CREATE'
                        WHEN request ILIKE 'DROP %' THEN 'DROP'
                        WHEN request ILIKE 'ALTER %' THEN 'ALTER'
                        WHEN request ILIKE 'GRANT %' THEN 'GRANT'
                        WHEN request ILIKE 'REVOKE %' THEN 'REVOKE'
                        ELSE 'OTHER DDL'
                      END
                    WHEN request ILIKE 'SELECT DROP_PARTITION%' THEN 'DROP PARTITION'
                    WHEN request ILIKE 'SELECT ANALYZE_STATISTICS%' OR request ILIKE 'SELECT ANALYZE_EXTERNAL_ROW_COUNT%' THEN 'ANALYZE STATS'
                    WHEN request ILIKE 'SET SESSION %' THEN 'SET SESSION'
                    WHEN request_type = 'QUERY' THEN
                      CASE
                        WHEN request ILIKE 'delete %' THEN 'DELETE'
                        WHEN REGEXP_ILIKE(regexp_replace(request, '\/\*\+direct\*\/', ' ', 1, 1, 'i'), '.*INSERT INTO\s+\w+\.\w+.*') THEN 'INSERT'
                        WHEN REGEXP_ILIKE(regexp_replace(request, '\/\*\+direct\*\/', ' ', 1, 1, 'i'), '.*UPDATE\s+\w+\.\w+.*') THEN 'UPDATE'
                        WHEN request ILIKE 'merge %' THEN 'MERGE'
                        WHEN request ILIKE 'SELECT%FROM%' THEN 'SELECT'
                        WHEN request ILIKE 'WITH%SELECT%FROM%' THEN 'WITH SELECT'
                        ELSE 'SELECT NO TABLE'
                      END
                    WHEN request_type = 'TRANSACTION' THEN
                      CASE
                        WHEN request ILIKE 'COMMIT%' THEN 'COMMIT'
                        WHEN request ILIKE 'ROLLBACK%' THEN 'ROLLBACK'
                      END
                    WHEN request_type = 'UTILITY' THEN
                      CASE
                        WHEN request ILIKE 'SELECT EXPORT_OBJECTS%' THEN 'EXPORT_OBJECTS'
                        WHEN request ILIKE 'SELECT%DO_TM_TASK%MERGEOUT%' THEN 'MANUAL MERGEOUT'
                        WHEN request ILIKE 'SELECT%DO_TM_TASK%MOVEOUT%' THEN 'MANUAL MOVEOUT'
                        WHEN request ILIKE 'SELECT%MAKE_AHM%' THEN 'MANUAL AHM'
                        WHEN request ILIKE 'SELECT internal_dfs_commit_changes%' THEN 'DFS COMMIT CHANGES'
                      END
                    ELSE NULL
                END request_subtype,
                *
        FROM query_requests
)
SELECT AVG(request_duration_ms)::INT, MAX(request_duration_ms), SUM(request_duration_ms), COUNT(*), SUM(CASE WHEN NOT success OR error_count IS NOT NULL THEN 1 ELSE 0 END) error_count, request_subtype
FROM query_types
WHERE
        user_name = 'dbadmin'
GROUP BY request_subtype
ORDER BY request_subtype;
