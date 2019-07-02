SELECT transaction_id, MAX(acquire_time) - MIN(time) queue_time, MAX(time) - MAX(acquire_time) execution_time, MAX(time) - MIN(time) request_duration
FROM dc_resource_releases
GROUP BY transaction_id
HAVING
        MAX(acquire_time) - MIN(time) > INTERVAL '1 second'
;
