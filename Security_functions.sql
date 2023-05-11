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
		-- raise exception '% is not % !', real_role, expected_role;
		return false;
	end if;
	
	return true;
end;
$$;


drop function check_user_access;
select check_user_access(1, 'sample_token', 'user');

select * from users;

update auth_tokens set expires_in = current_timestamp + interval '1 hour' where auth_token = 'sample_token';

select user_role.role_name from users inner join user_role on users.role_id = user_role.role_id where users.user_id = 1;