CREATE OR REPLACE PROCEDURE calculate_total_user_stats()
LANGUAGE plpgsql
AS $$
DECLARE
    total_users INTEGER;
    
   	rl_name VARCHAR(255);
   	rl_total_users INTEGER;
BEGIN
    -- Calculate total users
    SELECT COUNT(*) INTO total_users
    FROM users;
   
   	for  rl_name, rl_total_users IN 
   		SELECT user_role.role_name, COUNT(users)
    	FROM users 
    	inner join user_role on users.role_id = user_role.role_id
    	group by user_role.role_name
    loop
    	raise notice '% users with "%" role', rl_total_users, rl_name;
    end loop;
    
   
   	SELECT COUNT(*) INTO total_users
    FROM users;

    
    -- Output the result
    RAISE NOTICE 'Total users: %', total_users;
END;
$$;


create or replace procedure get_crypto_month_stats(
	publisher_id int,
	jwt varchar(255),
	ncrypto_name varchar(255)
)
language plpgsql
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
	
	select crypto_id from crypto where crypto_name = ncrypto_name into ncrypto_id; 
	if (ncrypto_id is null)
	then
		raise exception 'Crypto does not exists!';
	end if;

	view_name := FORMAT('crypto_shot_view_%s', crypto_name);
	nquery := "SELECT shot_time, price, market_cap, volume, transactions from" + w_name + "order by shot_time;";
	execute nquery;
	
end


-- call calculate_total_user_stats();







