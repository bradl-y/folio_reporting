--metadb:function get_item_circulation_history

DROP FUNCTION IF EXISTS get_item_circulation_history;

CREATE FUNCTION get_item_circulation_history(itm_barcode text)
RETURNS TABLE(
	date text,
	instance_hrid text,
	title text,
	item_barcode text,
	item_hrid text,
    call_number text,
    loan_record_uuid text,
    event_category text,
    event text,
    event_description text,
    patron_name text,
    patron_group text,
    patron_barcode text,
    patron_request_comments text,
    service_point text,
    source text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select
                to_char(((cl.jsonb->>'date')::timestamp AT TIME ZONE 'Australia/Canberra'), 'DD-MM-YYYY HH24:MI') AS date,
                it.hrid as instance_hrid,
                it.title,
                cl.jsonb->'items'->0->>'itemBarcode' as item_barcode,
                iit.hrid as item_hrid,
                hrt.call_number,
                cl.jsonb->'items'->0->>'loanId' as loan_record_uuid,
                cl.jsonb->>'object' as event_category,
                cl.jsonb->>'action' as event,
                cl.jsonb->>'description' as event_description,
                CONCAT(u.jsonb->'personal'->>'firstName', ' ', u.jsonb->'personal'->>'lastName') AS patron_name,
                gt.group as patron_group,
                cl.jsonb->>'userBarcode' as patron_barcode,
                cr.jsonb->>'patronComments' as patron_request_comments,
                (SELECT spt.name
                 FROM folio_inventory.service_point__t spt
                 WHERE (cl.jsonb->>'servicePointId')::uuid = spt.id) AS service_point,
                 cl.jsonb->>'source' as source
            from
                folio_audit.circulation_logs cl
                left join folio_users.users u on (cl.jsonb->'linkToIds'->>'userId')::uuid = u.id
                left join folio_users.groups__t gt on u.patrongroup = gt.id
                left join folio_inventory.instance__t it on (cl.jsonb->'items'->0->>'instanceId')::uuid = it.id
                left join folio_inventory.item__t iit on (cl.jsonb->'items'->0->>'itemId')::uuid = iit.id
                left join folio_circulation.request cr on (cl.jsonb->'linkToIds'->>'requestId')::uuid = cr.id
                left join folio_inventory.holdings_record__t hrt on (cl.jsonb->'items'->0->>'holdingId')::uuid = hrt.id
            where
                cl.jsonb->'items'->0->>'itemBarcode' = itm_barcode
            order by (cl.jsonb->>'date')::timestamp;
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE