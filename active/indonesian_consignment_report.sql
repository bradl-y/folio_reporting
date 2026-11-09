--metadb:function indonesian_consignment_report

DROP FUNCTION IF EXISTS indonesian_consignment_report;

CREATE FUNCTION indonesian_consignment_report(con_number text)
RETURNS TABLE(
	"Sequence Num" text,
	"Contributors" text,
	"Title" text,
	"Publisher" text,
	"Publication Place" text,
    "Publication Date" text,
    "Local Subject Term" text,
    "Created By" text,
    "Suppress" text,
    "Call Number" text,
    "JKT CONS Note" text,
    "POL Receipt Status" text
) AS
$$
BEGIN
    BEGIN
        RETURN QUERY
            select distinct
                substring(n->>'note' from '\/(\d+)') as "Sequence Num",
                i.jsonb->>'hrid' as "Instance HRID",
                bcumming.get_contributors(i.jsonb) as "Contributors",
                i.jsonb->>'title' as "Title",
                i.jsonb->'publication'->0->>'publisher' as "Publisher",
                i.jsonb->'publication'->0->>'place' as "Publication Place",
                i.jsonb->'publication'->0->>'dateOfPublication' as "Publication Date",
                (jsonb_path_query(i.jsonb->'notes', '$[*] ? (@.instanceNoteTypeId == "557ff81c-7fb2-45ab-a80a-89968f9f4059")')::jsonb)->>'note' AS "Local Subject Term",
                (SELECT CONCAT(
                            u.jsonb->'personal'->>'firstName',
                            ' ',
                            u.jsonb->'personal'->>'lastName'
                        )
                        FROM folio_users.users u
                        WHERE u.id = (i.jsonb->'metadata'->>'createdByUserId')::uuid
                    ) AS "Created By",
                CASE
                    WHEN NOT (i.jsonb->'discoverySuppress')::bool THEN 'False'
                    ELSE 'True'
                END AS "Suppress",
                hr.jsonb->>'callNumber' as "Call Number",
                n->>'note' as "JKT CONS Note",
                plt.receipt_status as "POL Receipt Status"
            from
                folio_inventory.instance i,
                folio_orders.po_line__t plt,
                folio_inventory.holdings_record hr
                CROSS JOIN LATERAL jsonb_array_elements(hr.jsonb->'notes') as n (jsonb)
            where
                n->>'note' like '%JKT CONS ' || con_number || '%'
                and i.id = hr.instanceId
                and plt.instance_id = i.id
            order by "Sequence Num";
    END;
END;
$$
LANGUAGE plpgsql
STABLE
PARALLEL SAFE
