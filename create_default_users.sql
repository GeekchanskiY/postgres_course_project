insert into USER_ROLE(role_name) values
('superuser'), ('user'), ('news_author'), ('unauthorized_user');

select gen_salt('bf')

select crypt('dummy', '$2a$06$gQKA6GXY/PJXJGupQwZTSO');

insert into users(user_name, user_password, salt, role_id) values
('dummy', '$2a$06$gQKA6GXY/PJXJGupQwZTSODRJLBdF34VQ2tAMrutGb777bfo5m.hO', '$2a$06$gQKA6GXY/PJXJGupQwZTSO', (select role_id from user_role where role_name = 'unauthorized_user'))

delete from user_role;