create role user_manager LOGIN;

grant execute on function create_standard_user to user_manager;
grant execute on function login_user to user_manager;


create role news_manager LOGIN;