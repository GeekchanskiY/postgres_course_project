''' JWT encode, decode and storing '''

from datetime import datetime, timedelta
import jwt


class JWTHolder:
    current_token: str
    algorithm = 'HS256'
    secret = 'secret'
    username: str
    role: str
    expires_in: str

    def __init__(self, username, role, algorithm=None, secret=None):
        self.username = username
        # self.uid = uid
        self.role = role

        if algorithm is not None:
            self.algorithm = algorithm
        if secret is not None:
            self.secret = secret

    def create_jwt(self, expires_in: datetime):
        self.expires_in = expires_in.strftime("%Y-%m-%d %H:%M:%S")
        self.current_token = jwt.encode(
            {
                # 'uid': self.uid,
                'username': self.username,
                'role': self.role,
                'expires_in': str(self.expires_in)
            },
            self.secret,
            algorithm=self.algorithm
        )

    def decode_jwt(self) -> str:

        return str(
            jwt.decode(
                self.current_token,
                self.secret,
                algorithms=[self.algorithm]
            )
        )

    def _check_lifetime(self) -> bool:
        expires_in = datetime.strptime(self.expires_in, "%Y-%m-%d %H:%M:%S")

        if expires_in > datetime.now():
            return False

        return True


if __name__ == "__main__":
    holder = JWTHolder('admin', 'superuser')
    holder.create_jwt(datetime.now() + timedelta(minutes=30))
    print(holder.current_token)
    print(holder.decode_jwt())
