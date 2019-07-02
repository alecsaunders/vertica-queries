SELECT projection_schema, anchor_table_name, SUM(used_bytes)
FROM projection_storage
GROUP BY 1, 2
ORDER BY 3 DESC;