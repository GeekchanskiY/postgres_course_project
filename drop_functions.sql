drop function if exists create_user(varchar(255), varchar(255), varchar(255));

drop function if exists delete_user(varchar(255), varchar(255));

drop function if exists create_standard_user(varchar(255), varchar(255));

drop function if exists login_user(varchar(255), varchar(255), varchar(255), varchar(255));

drop function if exists create_crypto(int, varchar(255), varchar(255), varchar(255), bytea,
numeric(18, 8), numeric(18, 8), numeric(18, 8), int);

drop function if exists create_crypto_shot(int, varchar(255), varchar(255), varchar(255),
numeric(18, 8), numeric(18, 8), numeric(18, 8), int);

drop function if exists get_my_id(varchar(255));

drop function if exists get_crypto_shots(
	timestamp,
	timestamp,
	
	varchar(255)
);

drop function if exists get_crypto_month_stats(
	int,
	varchar(255),
	varchar(255)
);

drop function if exists get_all_crypto_by_page(
	int,
	varchar(255),
	int, 
	int
);


drop function if exists get_all_crypto_comments(
	int,
	varchar(255),
	varchar(255)
);

drop function if exists get_my_likes(
	int,
	varchar(255)
);