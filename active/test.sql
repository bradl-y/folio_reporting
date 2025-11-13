--metadb:function bcumming.test

DROP FUNCTION IF EXISTS bcumming.test()

CREATE FUNCTION bcumming.test()
RETURNS TABLE(
    barcode text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select
                u.barcode
            from
                folio_users.users__t u
            where
                u.id = 'c3d090d0-e1bc-5a66-a54f-e029b66a2446';
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE;