''' JWT encode, decode and storing '''

import jwt


class JWTHolder:
    current_token: str = None
    algorithm = 'HS256'
    secret = 'secret'
    username: str
    uid: int
    role: str

    def __init__(self, uid, username, role, algorithm=None, secret=None):
        self.username = username
        self.uid = uid
        self.role = role

        if algorithm is not None:
            self.algorithm = algorithm
        if secret is not None:
            self.secret = secret

    def create_jwt(self):
        self.current_token = jwt.encode(
            {
                'uid': self.uid,
                'username': self.username,
                'role': self.role
            },
            self.secret,
            algorithm=self.algorithm
        )

    def decode_jwt(self) -> str:
        try:
            return str(
                jwt.decode(
                    self.current_token,
                    self.secret,
                    algorithms=[self.algorithm]
                )
            )
        except jwt.InvalidTokenError:
            return 'err'


if __name__ == "__main__":
    holder = JWTHolder('1', 'admin', 'superuser')
    holder.create_jwt()
    print(holder.current_token)
    print(holder.decode_jwt())
