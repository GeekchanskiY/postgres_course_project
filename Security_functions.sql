-- Security function to get user role and auth by provided jwt
create or replace function check_user_access(
	u_id INT,
	u_jwt VARCHAR(255),
	expected_role varchar(255)
) returns bool language plpgsql as $$
declare 
	real_id INT;
	real_role VARCHAR(255);
	expected_role_id INT;
	real_jwt VARCHAR(255);
	real_expires_in timestamp;
begin 
	select user_id, expires_in, auth_token from auth_tokens 
	where u_jwt = auth_token
	into real_id, real_expires_in, real_jwt;
	if (real_jwt is null)
	then
		raise exception 'No JWT found';
	end if;
	
	if (real_expires_in < current_timestamp)
	then
		return false;
	end if;
	
	-- select real role name
	select user_role.role_name from users 
	inner join user_role on users.role_id = user_role.role_id 
	where users.user_id = real_id into real_role;
	
	if (real_role != expected_role)
	then
		raise exception '% is not % !', real_role, expected_role;
		return false;
	end if;
	
	return true;
end;
$$;

CREATE OR replace FUNCTION create_crypto(
	publisher_id int,
	jwt varchar(255),
	new_crypto_name varchar(255),
	new_symbol varchar(255),
	new_image bytea,
	new_price numeric(18, 8),
	new_volume numeric(18, 8),
	new_market_cap numeric(18, 8),
	new_transaction_count INT
) returns void language plpgsql as $$
declare
	is_allowed bool;
begin
	select check_user_access(publisher_id, jwt, 'superuser') into is_allowed;
	if (is_allowed = false)
	then
		
		raise exception 'Not allowed!';
	end if;
	
	insert into crypto(crypto_name, symbol, image, price, volume, market_cap, transactions_count)
	values (new_crypto_name, new_symbol, new_image, new_price, new_volume, new_market_cap, new_transaction_count);
	
	return;
end;
$$;


-- drop function check_user_access;
-- select check_user_access(1, 'sample_token', 'superuser');



-- update users set role_id = 1 where user_id = 1;

-- update timestamp for tests
update auth_tokens set expires_in = current_timestamp + interval '1 hour', user_id = 1 where auth_token = 'sample_token';


--select create_crypto(
--	1,
--	'sample_token',
--	'Bitcoin',
--	'BTC',
--	'\x123131'::bytea,
--	12.3,
--	12.3,
--	12.3,
--	5
--);













