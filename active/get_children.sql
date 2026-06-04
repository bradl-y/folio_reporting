--metadb:function get_patron_loan_history

DROP FUNCTION IF EXISTS get_children;

CREATE FUNCTION get_children(parent_hrid text)
RETURNS TABLE(
	patron_barcode text,
	patron_name text,
	loan_status text,
	item_title text,
	loan_date text,
	loan_return_date text,
	item_barcode text,
	call_number text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select
				it.hrid,
				it.title,
                jsonb_extract_path_text(i.jsonb, 'contributors', '0', 'name') as first_contributor,
	            hrt.call_number
			from
				folio_inventory.instance i,
                folio_inventory.instance__t it,
                folio_inventory.holdings_record__t hrt,
                folio_derived.instance_alternative_titles iat
			where
				i.id = hrt.instance_id
                and i.id = it.id
                and i.id = iat.instance_id
                and iat.alternative_title_type_id = 'c0561f02-059a-4501-aca6-db5dcd4da3bf'
                and iat.alternative_title like '%' || parent_hrid;
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE