--metadb:function get_ld_records

DROP FUNCTION IF EXISTS get_ld_records;

CREATE FUNCTION get_ld_records(start_date text, end_date text)
RETURNS TABLE(
	instance_hrid text,
	title text,
	pol_receipt_date text,
	expense_class_code text,
	marc_format_code text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select
                i.jsonb->>'hrid' as instance_hrid,
                i.jsonb->>'title' as title,
                to_char((((pl.jsonb->>'receiptDate')::timestamptz
                    AT TIME ZONE 'Australia/Canberra')::date), 'DD-MM-YYYY') AS pol_receipt_date,
                ect.code as expense_class_code,
                substr(mrl.content->>'leader',7,2) as marc_format_code
            FROM
            folio_orders.po_line AS pl
            CROSS JOIN LATERAL
                jsonb_array_elements(pl.jsonb->'fundDistribution') AS ident (jsonb)
            LEFT JOIN folio_finance.expense_class__t AS ect
                ON (ident.jsonb->>'expenseClassId')::uuid = ect.id
            left join folio_inventory.instance i on (pl.jsonb->>'instanceId')::uuid = i.id
            left join folio_source_record.records_lb rl on (pl.jsonb->>'instanceId')::uuid = rl.external_id and rl.state = 'ACTUAL'
            left join folio_source_record.marc_records_lb mrl on mrl.id = rl.id
            where ect.code = any (
                    array[
                        'AUSMUS/LD',
                        'AUSMON/GD',
                        'AUSMON/LD',
                        'AUSMAPFRE/ATLD',
                        'AUSMAPFRE/ATGD',
                        'AUSMAPFRE/LD',
                        'AUSMAPFRE/GD'
                    ]
                )
            and ((pl.jsonb->>'receiptDate')::timestamptz
                AT TIME ZONE 'Australia/Canberra')::date
                BETWEEN TO_DATE(start_date, 'DD/MM/YYYY')
                    AND TO_DATE(end_date, 'DD/MM/YYYY')
            order by pol_receipt_date asc;
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE