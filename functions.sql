drop function create_user;

-- Function to check password strength
create or replace function check_password_strength(password varchar(255))
returns boolean
as $$
declare
    num_uppercase int;
    num_lowercase int;
    num_digits int;
    num_special int;
    repeated_chars int;
    i int;
begin
    if length(password) < 8 then
        return false;
    end if;
    
    num_uppercase := 0;
    num_lowercase := 0;
    num_digits := 0;
    num_special := 0;
    repeated_chars := 0;
    
    for i in 1..length(password) loop
        if substring(password from i for 1) ~ '[A-Z]' then
            num_uppercase := num_uppercase + 1;
        elsif substring(password from i for 1) ~ '[a-z]' then
            num_lowercase := num_lowercase + 1;
        elsif substring(password from i for 1) ~ '[0-9]' then
            num_digits := num_digits + 1;
        else
            num_special := num_special + 1;
        end if;
        
        if i < length(password) and substring(password from i for 1) = substring(password from i+1 for 1) then
            repeated_chars := repeated_chars + 1;
        end if;
    end loop;
    
    if num_uppercase = 0 or num_lowercase = 0 or num_digits = 0 or num_special = 0 or repeated_chars > 0 then
        return false;
    end if;
    
    return true;
end;
$$ language plpgsql;



-- Function to create user
create or replace function create_user(
	new_user_name varchar(255),
	new_user_password varchar(255),
	new_user_role_id int
) returns varchar(255) language plpgsql as $$
declare 
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
	select role_name from user_role where role_id = new_user_role_id into res;
	if (res is null)
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
	(new_user_name, hashed_password, salt, role_id);
	
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



select * from user_role;
select * from users;
select create_user('user123', 'paS$1234', 1);
select crypt('paS$1234', '$2a$06$EY0aB1bWDR3TCmIJtKdNru');
drop function login_user;
select login_user('user123', 'paS$1234', 'sample_token', '2023-05-10 10:30:00');



