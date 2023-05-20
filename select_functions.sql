create or replace function get_crypto_month_stats(
	publisher_id int,
	jwt varchar(255),
	ncrypto_name varchar(255)
) returns table(
	shot_time timestamp,
	price numeric(18, 8),
	market_cap numeric(18, 8),
	volume numeric(18, 8),
	transactions INT,
	diff numeric(18, 8),
	diffcap numeric(18,8)
	
) 
SECURITY definer language plpgsql
as $$
declare 
	is_allowed bool;
	ncrypto_id INT;
	view_name varchar(255);
	
	nquery text;
	
begin 
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;
	
	select crypto_id from CRYPTO where crypto_name = ncrypto_name into ncrypto_id; 
	if (ncrypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;

	view_name := FORMAT('crypto_shot_view_%s', ncrypto_name);
	--raise exception '%', view_name;
	nquery := FORMAT('SELECT shot_time, price, market_cap, volume, transactions, diff, diffcap from %s 
	where shot_time <= DATE_TRUNC(''month'', CURRENT_TIMESTAMP) + INTERVAL ''1 month'' order by shot_time;',
	quote_ident(view_name));
	--raise exception '%', nquery;
	return query execute nquery;
	
end;
$$;

--drop function get_crypto_month_stats;
--select get_crypto_month_stats(
--	1,
--	'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwaXJlc19pbiI6IjIwMjMtMDUtMjAgMTQ6MjE6MzMifQ.gmBllgSC6ZstLzinS2RvNwZjlc7ddlV4INiICcMs1m0',
--	'CustomCoin50'
--);
--  SELECT shot_time, price, market_cap, volume, transactions from "crypto_shot_view_CustomCoin50" 
--	where shot_time <= DATE_TRUNC('month', CURRENT_TIMESTAMP) + INTERVAL '2 month' order by shot_time;

create or replace function get_all_crypto_by_page(
	publisher_id int,
	jwt varchar(255),
	page int,
	per_page int
) returns table(
	crypto_name VARCHAR(255),
	symbol VARCHAR(10),
	image BYTEA,
	price numeric(18, 8),
	volume numeric(18, 8),
	market_cap numeric(18, 8),
	transactions_count INT
)
SECURITY definer language plpgsql
as $$
declare
	is_allowed bool;

	nquery text;

	start_id int;
	total_amount int;
	wasd int;
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;

	select count(*) from crypto into total_amount;
	wasd := (page) * per_page;
	if (total_amount < ((page) * per_page))
	then
		raise exception 'Out of range! %s', wasd;
	end if;
	start_id := page*per_page;
	nquery := FORMAT('select crypto_name, symbol, image, price, volume, 
	market_cap, transactions_count from crypto offset %s rows limit %s', 
	to_char(start_id, '999999'), to_char(per_page, '999999'));
	
	return query execute nquery;
	
end;
$$;


create or replace function get_all_crypto_comments(
	publisher_id int,
	jwt varchar(255),
	ncrypto_name varchar(255)
) returns table(
	title VARCHAR(255),
	review_text text,
	review_time timestamp,
	user_name varchar(255)
)
SECURITY definer language plpgsql
as $$
declare
	is_allowed bool;

	nquery text;

	ncrypto_id INT;
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;

	
	select crypto_id from CRYPTO where crypto_name = ncrypto_name into ncrypto_id; 
	if (ncrypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;

	
	
	return query select review.title, review.review_text, review.review_time, u.user_name 
	from crypto_review as review join
	users as u on u.user_id = review.user_id
	where review.crypto_id = ncrypto_id;
	
end;
$$;


create or replace function get_my_likes(
	publisher_id int,
	jwt varchar(255)
) returns table(
	crypto_name VARCHAR(255)
)
SECURITY definer language plpgsql
as $$
declare
	is_allowed bool;

	nquery text;

	ncrypto_id INT;
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;	
	
	return query select c.crypto_name 
	from CRYPTO_FAVOURITE as fav join
	crypto as c on fav.crypto_id = c.crypto_id 
	where fav.user_id = publisher_id;
end;
$$;

create or replace function search_crypto(
	publisher_id int,
	jwt varchar(255),
	ncrypto_name varchar(255)
) returns table(
	crypto_name VARCHAR(255),
	symbol VARCHAR(10),
	price numeric(18, 8),
	volume numeric(18, 8),
	market_cap numeric(18, 8),
	transactions_count INT
)
SECURITY definer language plpgsql
as $$
declare
	is_allowed bool;


	search_pattern text := '%' || ncrypto_name || '%';
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;

	
	
	return query select c.crypto_name, c.symbol, c.price, c.volume, 
	c.market_cap, c.transactions_count from crypto as c
	where c.crypto_name ilike search_pattern limit 100;
	
end;
$$;



-- select * from get_crypto_month_stats(1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwaXJlc19pbiI6IjIwMjMtMDUtMTkgMDg6MjM6NDUifQ.EuMYeL5o-XIGJqpHb2TOhADAlFGnkbwhb0tVZWS1ZbI', 'Bitcoin'); 
-- select * from get_all_crypto_by_page(1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwaXJlc19pbiI6IjIwMjMtMDUtMTkgMDg6NTU6MzcifQ.Of-MaBk3SGEegmu1NRz3XizgQDrqWeb8Myuj9OPyNco', 50, 20); 






