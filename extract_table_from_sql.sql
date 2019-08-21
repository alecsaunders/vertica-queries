/* INSERT */
SELECT
    REGEXP_REPLACE(
            REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REPLACE(
                                REGEXP_REPLACE(
                                        request,
                                        '\/\*\s?\+\s?direct\s?\*\/', ' ', 1, 1, 'i'
                                ),
                                '"', ''
                        ),
                        '^\s?INSERT\s+INTO\s+', '', 1, 0, 'i'
                    ),
                    '\s+.*', '', 1, 0, 'i'
            ),
            '\(.*', '', 1, 0, 'i'
    )
FROM query_requests
WHERE
    request ILIKE 'INSERT%'
;


/* COPY */
SELECT
        REGEXP_REPLACE(
                REGEXP_REPLACE(
                        REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                        REGEXP_REPLACE(request, '\/\*\s?\+\s?DIRECT\s?\*\/', '', 1, 0, 'i')  /* REMOVE DIRECT HINT */,
                                        '^\s?COPY\s+', '' /* REMOVE COPY FROM BEGINNING OF STATEMENT */
                                ),
                                '\s?\(.*', '' /* REMOVE COLUMN LISTING */
                        ),
                        '\"', '', 1, 1 /* REMOVE FIRST DOUBLE QUOTE TO EXPOSE CLOSING QUOTE FOR NEXT REGEX */
                ),
                '\".*', '' /* REMOVE EVERYTHING AFTER THE SECOND DOUBLE QUOTE */
        )
FROM query_requests
WHERE
        request ILIKE 'COPY%'
;