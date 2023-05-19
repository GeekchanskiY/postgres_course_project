create index if not exists idx_cryptoshottime on crypto_shot (crypto_id, shot_time);

create index if not exists idx_crypto_symbol on crypto (symbol);

create index if not exists idx_crypto_name on crypto (crypto_name);

create index if not exists idx_user_name on users (user_name);