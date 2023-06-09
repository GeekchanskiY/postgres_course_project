-- Function to create any user (only for superuser or sysdba)
create or replace function create_user(
	new_user_name varchar(255),
	new_user_password varchar(255),
	new_user_role_name varchar(255)
) returns varchar(255) SECURITY DEFINER language plpgsql as $$
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

create or replace function delete_user(
	old_user_name varchar(255),
	old_user_password varchar(255)
) returns varchar(255) SECURITY DEFINER language plpgsql as $$
declare 
	uid INT;
	login varchar(255);
	user_salt varchar(255);
	hashed_password varchar(255);
	user_pass varchar(255);
begin 
	select user_id, user_name, salt, user_password from users where user_name = old_user_name
	into uid, login, user_salt, hashed_password;
	if (login is null) 
	then
		raise exception 'User does not exists!';
	end if;

	select crypt(old_user_password, user_salt) into user_pass;

	if (user_pass = hashed_password)
	then
		delete from users where user_id = uid;
	else
		raise exception 'Incorrect password!';
	end if;
	return login;
end;
$$;

create or replace function create_standard_user(
	new_user_name varchar(255),
	new_user_password varchar(255)
)returns varchar(255) SECURITY definer language plpgsql as $$
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
) returns varchar(255) SECURITY DEFINER language plpgsql as $$
declare
	user_salt varchar(255);
	hashed_password varchar(255);
	
	uid int;
	user_token varchar(255);
	user_pass varchar(255);

	old_jwt varchar(255);
begin
	select user_id, user_name, salt, user_password from users where user_name = login
	into uid, login, user_salt, hashed_password;
	if (login is null) 
	then
		raise exception 'User does not exists!';
	end if;

	select crypt(pass, user_salt) into user_pass;

	if (user_pass != hashed_password)
	then
		-- Setting token to database
		-- data is being validated on server, so there is a potential block
		-- TODO: change this function and check token here
		raise exception 'Incorrect password!';
		--insert into auth_tokens(user_id, expires_in, auth_token) values
		--(uid, uexp_in::timestamp, jwt);
		--return 'success';
		
	end if;
	if ((select 1 from auth_tokens where user_id = uid) is not null)
	then
		select auth_token from auth_tokens
		where user_id = uid into old_jwt;
		select update_login_user(
			login,
			pass,
			jwt,
			uexp_in,
			old_jwt
		) into old_jwt;
		return 'Update user login success';
	end if;
	insert into auth_tokens(user_id, expires_in, auth_token) values
	(uid, uexp_in::timestamp, jwt);
	return 'success';
end;
$$;

create or replace function update_login_user(
	login varchar(255),
	pass varchar(255),
	jwt varchar(255),
	uexp_in varchar(255),
	old_jwt varchar(255)
) returns varchar(255) SECURITY DEFINER language plpgsql as $$
declare
	user_salt varchar(255);
	hashed_password varchar(255);
	
	old_token varchar(255);

	uid int;
	token_uid int;

	user_token varchar(255);
	user_pass varchar(255);
begin
	select user_id, user_name, salt, user_password from users where user_name = login
	into uid, login, user_salt, hashed_password;
	if (login is null) 
	then
		raise exception 'User does not exists!';
	end if;
	
	select auth_token from auth_tokens
	where auth_token = old_jwt
	into old_token;
	if (old_token is null)
	then
		raise exception 'Old auth does not exists!';
	end if;

	select crypt(pass, user_salt) into user_pass;

	if (user_pass = hashed_password)
	then
		-- Setting token to database
		-- data is being validated on server, so there is a potential block
		-- TODO: change this function and check token here
		UPDATE auth_tokens set expires_in = uexp_in::timestamp,
		auth_token = jwt where user_id = uid;
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
) returns void SECURITY definer language plpgsql as $$
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

CREATE OR replace FUNCTION delete_crypto(
	publisher_id int,
	jwt varchar(255),
	old_crypto_name varchar(255)
	
) returns void SECURITY DEFINER language plpgsql as $$
declare
	is_allowed bool;
	old_crypto_id int;
begin
	select check_user_access(publisher_id, jwt, 'superuser') into is_allowed;
	if (is_allowed = false)
	then
		
		raise exception 'Not allowed!';
	end if;

	select crypto_id from crypto where crypto_name = old_crypto_name into old_crypto_id;
	if (old_crypto_id is null)
	then
		raise exception 'crypto does not exists!';
	end if;
	
	delete from crypto where crypto_id = old_crypto_id;
	
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
) returns void SECURITY DEFINER language plpgsql as $$
declare
	is_allowed bool;
	shot_crypto_id INT;
begin
	select check_user_access(publisher_id, jwt, 'superuser') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;
	select crypto_id from crypto where crypto_name = shot_crypto_name into shot_crypto_id; 
	if (shot_crypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;
	insert into crypto_shot(shot_time, price, market_cap, volume, transactions, crypto_id)
	values (shot_shot_time::timestamp, shot_price, shot_market_cap, shot_volume, shot_transactions, shot_crypto_id);

	return;
end;
$$;

create or replace function toggle_crypto_like(publisher_id int, jwt varchar, cname varchar(255))
returns varchar(255) security definer language plpgsql as $$
declare 
	is_allowed bool;
	current_status bool;
	ccrypto_id int;
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;

	select crypto_id from crypto where crypto_name = cname into ccrypto_id;
	if (ccrypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;
	
	if (
	(select crypto_id from CRYPTO_FAVOURITE where crypto_id = ccrypto_id
	and user_id = publisher_id) is null) 
	then
		insert into CRYPTO_FAVOURITE(user_id, crypto_id)
		values (publisher_id, ccrypto_id);
		return 'liked';
	end if;
	
	delete from CRYPTO_FAVOURITE where crypto_id = ccrypto_id
	and user_id = publisher_id;
	return 'like removed';

end;
$$;

create or replace function crypto_comment(
publisher_id int, jwt varchar, cname varchar(255),
ctitle varchar(255), creview_text text)
returns varchar(255) security definer language plpgsql as $$
declare 
	is_allowed bool;
	current_status bool;
	ccrypto_id int;
begin
	select check_user_access(publisher_id, jwt, 'user') into is_allowed;
	if (is_allowed = false)
	then
		raise exception 'Not allowed!';
	end if;

	select crypto_id from crypto where crypto_name = cname into ccrypto_id;
	if (ccrypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;
	
	if (
	(select crypto_id from crypto_review where crypto_id = ccrypto_id
	and user_id = publisher_id) is null) 
	then
		insert into CRYPTO_review(user_id, crypto_id, title, review_text)
		values (publisher_id, ccrypto_id, ctitle, creview_text);
		return 'review added';
	end if;
	
	
	update CRYPTO_review set title = ctitle, review_text = creview_text
	where crypto_id = ccrypto_id and user_id = publisher_id;
	return 'review updated';
end;
$$;


-- Get my id bases on jwt because you should not know other id's
create or replace function get_my_id(
	jwt varchar(255)
) returns INTEGER SECURITY DEFINER language plpgsql as $$
declare
	uid INT;
begin
	select user_id from auth_tokens where auth_token = jwt into uid;
	if (uid is null)
	then
		raise exception 'Token does not exists!';
	end if;
	return uid;
end;
$$;

create or replace function get_crypto_shots(
	start_time timestamp,
	end_time timestamp,
	
	ncrypto_name varchar(255)
) returns void language plpgsql as $$ 
declare
	ncrypto_id INT;
	view_name varchar(255);
	
	nquery text;
	
begin
		select crypto_id from crypto where crypto_name = ncrypto_name into ncrypto_id; 
		if (ncrypto_id is null)
		then
			raise exception 'Crypto does not exists!';
		end if;
	
	view_name := FORMAT('crypto_shot_view_%s', crypto_name);
	nquery := "SELECT DATE_TRUNC('day', shot_time) as day, avg(price) from" + w_name + "group by day order by day;";
	execute nquery;
	return;
end;
$$;

