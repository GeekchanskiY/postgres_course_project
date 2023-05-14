do
$$
begin
  if not exists (select * from pg_user where usename = 'user_master') then
     create user user_master with password 'DummyP4S$W0RD';
     grant user_manager to user_master;
  end if;
end
$$;



do
$$
begin
  if not exists (select * from pg_user where usename = 'news_master') then
     create user news_master with password 'DummyP4S$W0RD';
     grant news_manager to news_master;
  end if;
end
$$;


do
$$
begin
  if not exists (select * from pg_user where usename = 'crypto_master') then
     create user crypto_master with password 'DummyP4S$W0RD';
     grant crypto_manager to news_master;
  end if;
end
$$;