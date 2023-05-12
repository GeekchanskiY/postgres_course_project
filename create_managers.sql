do
$$
begin
  if not exists (select * from pg_user where usename = 'user_master') then
     create user user_master with password 'DummyP4S$W0RD';
  end if;
end
$$;

grant user_manager to user_master;