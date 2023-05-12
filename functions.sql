-- Function to create any user (only for superuser or sysdba)
create or replace function create_user(
	new_user_name varchar(255),
	new_user_password varchar(255),
	new_user_role_name varchar(255)
) returns varchar(255) language plpgsql as $$
declare 
	new_user_role_id INT;
	res varchar(255);
	bres bool;
	salt varchar(255);
	hashed_password varchar(255);
begin
	
	-- Check if user does not exists
	select user_name from users where user_name = new_user_name into res;
	if (res is not null) 
	then 
		raise exception 'User already exists!';
	end if;
	
	-- Check if role exists
	select role_id from user_role where role_name = new_user_role_name into new_user_role_id;
	if (new_user_role_id is null)
	then
		raise exception 'Incorrect role!';
	end if;
	
	-- Check if password is strong
	select check_password_strength(new_user_password) into bres;
	if (bres = false)
	then 
		raise exception 'Password is weak!';
	end if;
	
	-- generate salt and crypt password for user
	select gen_salt('bf') into salt;
	select crypt(new_user_password, salt) into hashed_password;

	insert into users(user_name, user_password, salt, role_id) values
	(new_user_name, hashed_password, salt, new_user_role_id);
	
	return new_user_name;
end;
$$;

create or replace function create_standard_user(
	new_user_name varchar(255),
	new_user_password varchar(255)
)returns varchar(255) language plpgsql as $$
declare 
	new_user_role_id INT;
	res varchar(255);
	bres bool;
	salt varchar(255);
	hashed_password varchar(255);
begin
	
	-- Check if user does not exists
	select user_name from users where user_name = new_user_name into res;
	if (res is not null) 
	then 
		raise exception 'User already exists!';
	end if;
	
	-- Select standart
	select role_id from user_role where role_name = 'user' into new_user_role_id;
	
	
	-- Check if password is strong
	select check_password_strength(new_user_password) into bres;
	if (bres = false)
	then 
		raise exception 'Password is weak!';
	end if;
	
	-- generate salt and crypt password for user
	select gen_salt('bf') into salt;
	select crypt(new_user_password, salt) into hashed_password;

	insert into users(user_name, user_password, salt, role_id) values
	(new_user_name, hashed_password, salt, new_user_role_id);
	
	return new_user_name;
end;
$$;

create or replace function login_user(
	login varchar(255),
	pass varchar(255),
	jwt varchar(255),
	uexp_in varchar(255)
) returns varchar(255) language plpgsql as $$
declare
	user_salt varchar(255);
	hashed_password varchar(255);
	
	uid int;
	user_token varchar(255);
	user_pass varchar(255);
begin
	select user_id, user_name, salt, user_password from users where user_name = login
	into uid, login, user_salt, hashed_password;
	if (login is null) 
	then
		raise exception 'user does not exists';
	end if;

	select crypt(pass, user_salt) into user_pass;

	if (user_pass = hashed_password)
	then
		-- Setting token to database
		-- data is being validated on server, so there is a potential block
		-- TODO: change this function and check token here
		insert into auth_tokens(user_id, expires_in, auth_token) values
		(uid, uexp_in::timestamp, jwt);
		return 'success';
	else
		raise exception 'Incorrect password!';
	end if;
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
	select check_user_access(publisher_id, jwt, 'admin') into is_allowed;
	if (is_allowed = false)
	then
		
		raise exception 'Not allowed!';
	end if;
	
	insert into crypto(crypto_name, symbol, image, price, volume, market_cap, transactions_count)
	values (new_crypto_name, new_symbol, new_image, new_price, new_volume, new_market_cap, new_transaction_count);
	
	return;
end;
$$;

create or replace function create_crypto_shot(
	publisher_id int,
	jwt varchar(255),
	
	shot_crypto_name varchar(255), 
	shot_shot_time varchar(255),
	shot_price numeric(18, 8),
	shot_market_cap numeric(18, 8),
	shot_volume numeric(18, 8),
	shot_transactions INT
) returns void language plpgsql as $$
declare
	is_allowed bool;
	shot_crypto_id INT;
begin
	select check_user_access(publisher_id, jwt, 'admin') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;
	select crypto_id from crypto where crypto_name = shot_crypto_name into shot_crypto_id; 
	if (shot_crypto_id is null)
	then
		raise exception 'Wrong crypto name!';
	end if;
	insert into crypto_shot(shot_time, price, market_cap, volume, transactions, crypto_id)
	values (shot_shot_time::timestamp, shot_price, shot_market_cap, shot_volume, shot_transactions, shot_crypto_id);

	return;
end;
$$;

create or replace function get_crypto_shots(
	start_time timestamp,
	end_time timestamp,
	
	ncrypto_name varchar(255)
) returns table (
	shot_time timestamp,
	price numeric(18, 8),
	market_cap numeric(18, 8),
	volume numeric(18, 8),
	transactions int
) language plpgsql as $$ 
declare
	ncrypto_id INT;
	view_name varchar(255);
	
begin
	select crypto_id from crypto where crypto_name = ncrypto_name;
	if (crypto_id is null)
	then
		raise exception 'Invalid crypto id!'
	end if;
	
	view_name := FORMAT('crypto_shot_view_%s', crypto_name);
end;
$$;


--select * from users;
--select create_standard_user('user1234', 'paS$1234');
--delete from user_role where role_id = 4;
--select create_user('user123', 'paS$1234', 1);
--select crypt('paS$1234', '$2a$06$EY0aB1bWDR3TCmIJtKdNru');
--drop function login_user;
--select login_user('user123', 'paS$1234', 'sample_token', '2023-05-10 10:30:00');

-- update auth_tokens set expires_in = current_timestamp + interval '1 hour', user_id = 1 where auth_token = 'sample_token';



