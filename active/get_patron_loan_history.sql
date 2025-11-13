--metadb:function get_patron_loan_history

DROP FUNCTION IF EXISTS get_patron_loan_history

CREATE FUNCTION get_patron_loan_history(patron_uuid text)
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
				u.jsonb->>'barcode' as patron_barcode,
				concat_ws(' ', u.jsonb->'personal'->>'firstName', u.jsonb->'personal'->>'lastName') as patron_name,
				li.loan_status as loan_status,
				ihi.title as title,
				to_char(li.loan_date, 'DD-MM-YYYY HH:MI am') as loan_date,
				to_char(li.loan_return_date, 'DD-MM-YYYY HH:MI am') as loan_return_date,
				li.barcode as item_barcode,
				ihi.call_number as call_number
			from
				folio_derived.loans_items li,
				folio_users.users u,
				folio_derived.items_holdings_instances ihi
			where
				li.user_id = patron_uuid::UUID
				and li.user_id = u.id
				and li.item_id = ihi.item_id;
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE