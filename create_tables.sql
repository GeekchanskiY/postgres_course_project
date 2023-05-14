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
	expires_in TIMESTAMP default current_timestamp not null,
	auth_token varchar(255) not null,
	
	constraint FK_USER foreign key(user_id) references USERS(user_id) on delete cascade
) tablespace TS_USER;

create table if not exists CRYPTO (
	crypto_id serial primary key,
	crypto_name VARCHAR(255) unique not null,
	symbol VARCHAR(10) not null,
	image BYTEA not null,
	price numeric(18, 8) not null,
	volume numeric(18, 8) not null,
	market_cap numeric(18, 8) not null,
	transactions_count INT not null,
	
	constraint positive_transactions check (transactions_count >= 0),
	constraint positive_volume check (volume >= 0),
	constraint positive_mkt_cap check (market_cap >= 0),
	constraint positive_price check (price >= 0)
) tablespace TS_CRYPTO;

create table if not exists CRYPTO_SHOT (
	shot_id serial primary key,
	shot_time timestamp not null,
	price numeric(18, 8) not null,
	market_cap numeric(18, 8) not null,
	volume numeric(18, 8) not null,
	transactions INT not null,
	
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
	review_text text not null,
	review_time timestamp default current_timestamp not null,
	
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







