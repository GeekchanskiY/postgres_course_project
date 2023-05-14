do $$
begin
if ((select rolname from pg_roles where rolname = 'user_manager') is null)
then 
	create role user_manager LOGIN;
	grant execute on function create_standard_user to user_manager;
	grant execute on function login_user to user_manager;
end if;
end;
$$;


do $$
begin
if ((select rolname from pg_roles where rolname = 'news_manager') is null)
then 
	create role news_manager LOGIN;
end if;
end;
$$;

do $$
begin
if ((select rolname from pg_roles where rolname = 'crypto_manager') is null)
then 
	create role crypto_manager LOGIN;
end if;
end;
$$;




