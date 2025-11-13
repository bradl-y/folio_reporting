--metadb:function bcumming.dummy

CREATE or replace FUNCTION bcumming.dummy(
    user_gr text DEFAULT ''
)
RETURNS TABLE(
    id uuid,
    groups text
) AS
$$
/* Code block */
BEGIN
    /* PROCEDURE section */
    BEGIN
        RETURN QUERY
            SELECT
                groups__t.id AS id,
                groups__t.group AS groups
            FROM
                folio_users.groups__t
            WHERE
                ((groups__t.group = user_gr) OR (user_gr = ''));
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE
;