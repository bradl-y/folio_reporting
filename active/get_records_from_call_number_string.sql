--metadb:function get_records_from_call_number_string

DROP FUNCTION IF EXISTS get_records_from_call_number_string;

CREATE FUNCTION get_records_from_call_number_string(cn_str text)
RETURNS TABLE(
	instance_hrid text,
	title text,
	first_contributor text,
    holding_hrid text,
	call_number text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select
				it.hrid as hrid,
				it.title as title,
                jsonb_extract_path_text(i.jsonb, 'contributors', '0', 'name') as first_contributor,
                hrt.hrid as holding_hrid,
	            hrt.call_number as call_number
			from
				folio_inventory.instance i,
                folio_inventory.instance__t it,
                folio_inventory.holdings_record__t hrt
			where
			    hrt.call_number ilike '%' || cn_str || '%'
                and hrt.instance_id = it.id
                and i.id = it.id;
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE