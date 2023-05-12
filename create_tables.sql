create table if not exists USER_ROLE (
	role_id serial primary key,
	role_name varchar(50) unique not null
) tablespace TS_USER;

create table if not exists USERS (
	user_id serial primary key,
	user_name varchar(255) not null unique,
	user_password varchar(255) not null,
	salt varchar(255) not null,
	role_id INT,
	constraint FK_ROLE foreign key(role_id) references USER_ROLE(role_id) on delete cascade
) tablespace TS_USER;

create table if not exists AUTH_TOKENS (
	user_id INT unique not null,
	expires_in TIMESTAMP default current_timestamp,
	auth_token varchar(255),
	
	constraint FK_USER foreign key(user_id) references USERS(user_id) on delete cascade
)

create table if not exists CRYPTO (
	crypto_id serial primary key,
	crypto_name VARCHAR(255) unique not null,
	symbol VARCHAR(10) not null,
	image BYTEA not null,
	price numeric(18, 8),
	volume numeric(18, 8),
	market_cap numeric(18, 8),
	transactions_count INT,
	
	constraint positive_transactions check (transactions_count >= 0),
	constraint positive_volume check (volume >= 0),
	constraint positive_mkt_cap check (market_cap >= 0),
	constraint positive_price check (price >= 0)
) tablespace TS_CRYPTO;

create table if not exists NEWS (
	news_id serial primary key,
	user_id INT not null,
	title varchar(255),
	contents text,
	constraint FK_NEWS_AUTHOR foreign key(user_id) references USERS(user_id) on delete cascade
) tablespace TS_NEWS;

create table if not exists NEWSLIKE (
	user_id INT,
	news_id INT,
	
	UNIQUE(user_id, news_id),
	
	constraint FK_NEWS_LIKED foreign key(news_id) references NEWS(news_id) on delete cascade,
	constraint FK_USER_LIKED foreign key(user_id) references USERS(user_id) on delete cascade
) tablespace TS_NEWS;

create table if not exists NEWSCOMMENT (
	comment_id serial primary key,
	user_id INT not null,
	news_id INT not null,
	newstext text,
	publish_time timestamp,
	
	constraint FK_NEWS_COMMENTED foreign key(news_id) references NEWS(news_id) on delete cascade,
	constraint FK_USER_COMMENTED foreign key(user_id) references USERS(user_id) on delete cascade,
	
	CONSTRAINT check_publish_time CHECK (publish_time <= CURRENT_TIMESTAMP)
	
) tablespace TS_NEWS;

create table if not exists NEWSIMAGE(
	news_id INT not null,
	image BYTEA not null,
	constraint FK_NEWS_IMAGE foreign key(news_id) references NEWS(news_id) on delete cascade
) tablespace TS_NEWS;

create table if not exists CRYPTO_SHOT (
	shot_id serial primary key,
	shot_time timestamp,
	price numeric(18, 8),
	market_cap numeric(18, 8),
	volume numeric(18, 8),
	transactions INT,
	
	crypto_id INT not null,
	constraint FK_CRYPTO foreign key(crypto_id) references CRYPTO(crypto_id) on delete cascade,
	
	constraint positive_transactions check (transactions >= 0),
	constraint positive_volume check (volume >= 0),
	constraint positive_mkt_cap check (market_cap >= 0),
	constraint positive_price check (price >= 0)
) tablespace TS_CRYPTO;

create table if not exists CRYPTO_REVIEW (
	review_id serial primary key,
	title VARCHAR(255) not null,
	review_text text,
	review_time timestamp default current_timestamp,
	
	user_id INT not null,
	crypto_id INT not null,
	
	constraint FK_USER foreign key(user_id) references USERS(user_id) on delete cascade,
	constraint FK_CRYPTO foreign key(crypto_id) references CRYPTO(crypto_id) on delete cascade

) tablespace TS_CRYPTO;

create table if not exists CRYPTO_FAVOURITE(
	user_id INT not null,
	crypto_id INT not null,
	
	UNIQUE(user_id, crypto_id),
	
	constraint FK_USER foreign key(user_id) references USERS(user_id) on delete cascade,
	constraint FK_CRYPTO foreign key(crypto_id) references CRYPTO(crypto_id) on delete cascade
) tablespace TS_USER;







