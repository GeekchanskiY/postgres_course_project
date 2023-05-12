do $$
begin
if (select rolname from pg_roles where rolname = 'user_manager') != 'user_manager'
then 
	create role user_manager LOGIN;
end if;
end;
$$;


grant execute on function create_standard_user to user_manager;
grant execute on function login_user to user_manager;


do $$
begin
if (select rolname from pg_roles where rolname = 'news_manager') != 'news_manager'
then 
	create role news_manager LOGIN;
end if;
end;
$$;

do $$
begin
if (select rolname from pg_roles where rolname = 'crypto_manager') != 'crypto_manager'
then 
	create role crypto_manager LOGIN;
end if;
end;
$$;
