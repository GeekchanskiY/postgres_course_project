create or replace FUNCTION update_crypto_shot_view()
RETURNS TRIGGER AS
$$
declare
	depending_crypto_name varchar(255);
	view_name varchar(255);
BEGIN
    select crypto.crypto_name from crypto 
    where new.crypto_id = crypto.crypto_id
    into depending_crypto_name;
   	
   	view_name := FORMAT('crypto_shot_view_%s', depending_crypto_name);
   	
   	execute FORMAT('REFRESH MATERIALIZED VIEW %s', view_name);
   
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'update_crypto_shot_view_trigger'
    ) THEN
        create trigger update_crypto_shot_view_trigger
		after insert or update on crypto_shot
		execute function update_crypto_shot_view();
    END IF;
END;
$$;

