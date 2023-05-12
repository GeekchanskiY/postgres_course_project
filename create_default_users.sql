insert into USER_ROLE(role_name) values
('superuser'), ('user'), ('news_author'), ('admin') ON CONFLICT DO NOTHING;