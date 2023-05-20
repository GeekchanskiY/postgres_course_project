do $$
begin
if ((select rolname from pg_roles where rolname = 'user_manager') is null)
then 
	create role user_manager LOGIN;
	grant insert on users to user_manager;
	grant execute on function create_user to user_manager;
	grant execute on function create_standard_user to user_manager;
	grant execute on function login_user to user_manager;
	grant execute on function get_my_id to user_manager;
	grant execute on function crypto_comment to user_manager;
	grant execute on function toggle_crypto_like to user_manager;
	grant execute on function update_login_user to user_manager;
	grant execute on function get_my_likes to user_manager;
end if;
end;
$$;

do $$
begin
if ((select rolname from pg_roles where rolname = 'crypto_manager') is null)
then 
	create role crypto_manager LOGIN;
	grant execute on function create_crypto to crypto_manager;
	grant execute on function get_crypto_shots to crypto_manager;
	grant execute on function delete_crypto to crypto_manager;
	grant execute on function get_crypto_month_stats to crypto_manager;
	grant execute on function get_all_crypto_by_page to crypto_manager;
	grant execute on function get_all_crypto_comments to crypto_manager;
	grant execute on function search_crypto to crypto_manager;
end if;
end;
$$;