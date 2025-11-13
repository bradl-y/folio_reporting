--metadb:function bcumming.test

DROP FUNCTION IF EXISTS bcumming.test;

CREATE FUNCTION bcumming.test()
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
declare
thisUserName varchar = '';

begin
	select
	username
into
	thisUserName
from
	folio_users.users__t ut
where
	ut.id = 'c3d090d0-e1bc-5a66-a54f-e029b66a2446';

return thisUserName;
end;

$function$
;