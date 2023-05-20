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
   
   	if (depending_crypto_name is null)
   	then
   	raise exception '%', new.crypto_id;
   end if;
   	
   	view_name := FORMAT('crypto_shot_view_%s', depending_crypto_name);
   	
   	execute FORMAT('REFRESH MATERIALIZED VIEW "%s"', view_name);
   
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
		after insert or update on crypto_shot for each row
		execute function update_crypto_shot_view();
    END IF;
END;
$$;



create or replace function create_shot_view_with_crypto()
returns trigger as
$$
declare 
	view_name varchar(255);
	depending_crypto_name varchar(255);
	depending_crypto_id INT;
	wow text;
begin
	depending_crypto_name := new.crypto_name;
	depending_crypto_id := new.crypto_id;
	if (depending_crypto_id is null)
	then
		RAISE exception 'a';
	end if;
	view_name := FORMAT('crypto_shot_view_%s', depending_crypto_name);
	wow := FORMAT(
    'CREATE MATERIALIZED VIEW %I AS
     SELECT s1.shot_time, s1.price, s1.market_cap, s1.volume, s1.transactions, 
	 s1.price - s2.price as diff, s1.market_cap - s2.market_cap as diffcap
     FROM crypto_shot as s1
	 join crypto_shot as s2 on 
	 s2.shot_id = (select s3.shot_id from crypto_shot
	 as s3 where s3.crypto_id = s1.crypto_id
	 order by shot_time limit 1)
     WHERE s1.crypto_id = %s
     ORDER BY shot_time
	 limit 30',
     view_name,
     depending_crypto_id
	);
	execute wow;
	
	return new;
end;
$$ language plpgsql;

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'create_shot_view_with_crypto_trigger'
    ) THEN
        create trigger create_shot_view_with_crypto_trigger
		after insert or update on crypto for each row
		execute function create_shot_view_with_crypto();
    END IF;
END;
$$;

create or replace function drop_shot_view_with_crypto()
returns trigger as
$$
declare 
	view_name varchar(255);
	depending_crypto_name varchar(255);
	depending_crypto_id INT;
	wow text;
begin
	depending_crypto_name := old.crypto_name;
	depending_crypto_id := old.crypto_id;
	if (depending_crypto_id is null)
	then
		RAISE exception 'a';
	end if;
	view_name := FORMAT('crypto_shot_view_%s', depending_crypto_name);
	-- IF exists is unnecessary here, but i used it to avoid
	-- errors during development
	wow := FORMAT(
    'DROP MATERIALIZED VIEW IF EXISTS %I ',
     view_name,
     depending_crypto_id
	);
	execute wow;
	
	return new;
end; 
$$ language plpgsql;

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'drop_shot_view_with_crypto_trigger'
    ) THEN
        create trigger drop_shot_view_with_crypto_trigger
		after delete on crypto for each row
		execute function drop_shot_view_with_crypto();
    END IF;
END;
$$;

-- select count(*) from crypto;

