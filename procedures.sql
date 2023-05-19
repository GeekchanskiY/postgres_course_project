CREATE OR REPLACE PROCEDURE calculate_total_user_stats()
SECURITY definer LANGUAGE plpgsql
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


-- call calculate_total_user_stats();





