insert into USER_ROLE(role_name) values
('superuser'), ('user'), ('news_author'), ('unauthorized_user');

select crypt('123', gen_salt('bf'));

insert into users(user_name, user_password, role_id) values
('dummy', 'dummy', (select role_id from user_role where role_name = 'unauthorized_user'))

delete from user_role;