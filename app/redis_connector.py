import redis


class RedisConnector:

    def __init__(self) -> None:
        self.client = redis.Redis(host='localhost', port=6379, db=0, password='password')

    def set_jwt(self, username, jwt, expires_in):
        self.client.set(f'users/{username}/jwt', jwt)
        self.client.set(f'users/{username}/expire_time', expires_in)

    def get_expires_in(self, username) -> str | None:
        data = self.client.get(f'users/{username}/expire_time')
        if data is not None:
            data = str(data, 'utf-8')
        return data

    def get_jwt(self, username):
        data = self.client.get(f'users/{username}/jwt')
        if data is not None:
            data = str(data, 'utf-8')
        return data

    def flush(self):
        self.client.flushdb()


if __name__ == "__main__":
    rds = RedisConnector()
