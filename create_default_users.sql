insert into USER_ROLE(role_name) values
('superuser'), ('user'), ('admin') ON CONFLICT DO NOTHING;

select create_user('admin', 'superP4$Sw0rD', 'superuser')
WHERE NOT EXISTS (
    SELECT 1 FROM users
    WHERE user_name = 'admin'
);