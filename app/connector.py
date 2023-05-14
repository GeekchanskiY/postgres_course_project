''' PGSQL connection logic here '''

from datetime import datetime, timedelta

from sqlalchemy import create_engine, text
from sqlalchemy.exc import DBAPIError
# import psycopg2
# from sqlalchemy.schema import Sequence

from JWT_logic import JWTHolder

#
#   Exceptions block
#


class InvalidPrivelegeExceprion(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(self.message)


class RoleDoesNotExists(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(self.message)


class UserAlreadyExistsException(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(self.message)


class UserDoesNotExistsException(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)


class WeakPasswordException(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)


class DoesNotExistsException(Exception):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)

#
# Connectors
#


class CustomConnector:
    ''' Base Connector class with all priveleges. Use only for tests! '''

    rolename = 'postgres'

    jwt: JWTHolder

    def __init__(self, user, password):
        # self.conn = psycopg2.connect(
        #     host='0.0.0.0',
        #     database='postgres',
        #     user=user,
        #     password=password
        # )
        self.engine = create_engine(
            f'postgresql+psycopg2://{user}:{password}@0.0.0.0/postgres'
        )
        self._check_role()
        # self.cur = self.conn.cursor()

    def _check_role(self):
        if self._get_role() != self.rolename:
            raise InvalidPrivelegeExceprion(f'You do not have \'{self.rolename}\' role!')

    def _get_role(self) -> str | None:
        rolname = self._exec(
            'SELECT rolname '
            'FROM pg_roles '
            'WHERE rolname = current_user;'
        )
        if rolname is not None:
            return str(rolname[0][0])

    def _exec(self, query_str: str) -> list | None:
        # self.cur.execute(query_str)
        # res = self.cur.fetchall()
        with self.engine.connect() as conn:
            try:
                result = conn.execute(text(query_str))
                conn.execute(text('COMMIT'))
                return list(result.all())
            except DBAPIError as e:
                self._handle_exception(str(e.orig))

    def _get_exception_text(self, orig: str) -> str:
        return orig.split('\n')[0]

    def _handle_exception(self, e_text: str) -> None:

        e_text = self._get_exception_text(e_text)

        # TODO: add additional parameters
        # to make Exception more informative

        if e_text == "Password is weak!":
            raise WeakPasswordException(e_text)
        elif e_text == 'User already exists!':
            raise UserAlreadyExistsException(e_text)
        elif e_text == 'User does not exists!':
            raise UserDoesNotExistsException(e_text)
        elif e_text == 'Not allowed!':
            raise InvalidPrivelegeExceprion(e_text)
        elif e_text == 'Crypto does not exists!' or \
                e_text == 'Token does not exists!' or \
                e_text == 'News does not exists!':
            raise DoesNotExistsException(e_text)
        else:
            raise Exception('New_exception: ' + e_text)


class CustomPostgresConnector(CustomConnector):
    ''' Postgres connector with all permissions and methods. Use Only for tests! '''

    rolename = 'postgres'

    available_roles = ['superuser', 'user', 'news_author', 'admin']

    # token_live_time = timedelta(minutes=30)

    def __init__(self, user, password):
        super().__init__(user, password)

    def create_user(self, username, password, role) -> str:
        res = self._exec(
            f"select create_user('{username}', '{password}', '{role}')"
        )
        return str(res)

    def delete_user(self, username, password) -> str:
        res = self._exec(
            f"select delete_user('{username}', '{password}')"
        )
        return str(res)

    def login_user(self, username, password) -> str:
        self.jwt = JWTHolder(username)
        token = self.jwt.get_jwt()
        exp_in = self.jwt.expires_in

        res = self._exec(
            f"select login_user('{username}', '{password}', '{token}', '{exp_in}' )"
        )
        return str(res)


class UserMasterConnector(CustomConnector):
    ''' User master with users manage priveleges and methods '''

    rolename = 'user_master'

    def __init__(self, user, password):
        super().__init__(user, password)


class NewsMasterConnector(CustomConnector):
    ''' News master to manage news '''

    rolename = 'news_manager'

    def __init__(self, user, password):
        super().__init__(user, password)


class CryptoMasterConnector(CustomConnector):
    ''' Crypto master with crypto manage priveleges and methods '''

    rolename = 'crypto_manager'

    def __init__(self, user, password):
        super().__init__(user, password)


if __name__ == '__main__':
    admin = CustomPostgresConnector('postgres', 'postgres')
    admin.create_user("Dimka", "DimkaP4S$W0RD", "superuser")
    print(admin._exec('SELECT * FROM USERS'))
    admin.login_user("Dimka", "DimkaP4S$W0RD")
    print(admin._exec('select * FROM auth_tokens'))
    # admin.delete_user("Dimka", "DimkaP4S$W0RD")
    user = UserMasterConnector('user_master', 'DummyP4S$W0RD')
