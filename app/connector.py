''' PGSQL connection logic here '''

from sqlalchemy import create_engine, text
from sqlalchemy.exc import DBAPIError
# import psycopg2
# from sqlalchemy.schema import Sequence

#
#   Exceptions block
#


class InvalidPrivelegeExceprion(Exception):
    def __init__(self, message) -> None:
        self.message = message
        super().__init__(self.message)


class RoleDoesNotExists(Exception):
    def __init__(self, message) -> None:
        self.message = message
        super().__init__(self.message)


class UserAlreadyExistsException(Exception):
    def __init__(self, message) -> None:
        self.message = message
        super().__init__(self.message)


class WeakPasswordException(Exception):
    def __init__(self, message) -> None:
        self.message = message
        super().__init__(message)


#
# Connectors
#


class CustomConnector:
    ''' Base Connector class with all priveleges. Use only for tests! '''

    rolename = 'postgres'

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

    def _get_role(self) -> str:
        rolname = self._exec(
            'SELECT rolname '
            'FROM pg_roles '
            'WHERE rolname = current_user;'
        )[0][0]
        return str(rolname)

    def _exec(self, query_str: str) -> list:
        # self.cur.execute(query_str)
        # res = self.cur.fetchall()
        with self.engine.connect() as conn:
            result = conn.execute(text(query_str))
        return list(result.all())

    def _get_exception_text(self, orig: str) -> str:
        return orig.split('\n')[0]

    def _handle_exception(self, e_text: str) -> None:
        e_text = self._get_exception_text(e_text)
        if e_text == "Password is weak!":
            raise WeakPasswordException(e_text)


class CustomPostgresConnector(CustomConnector):
    ''' Postgres connector with all permissions and methods. Use Only for tests! '''

    rolename = 'postgres'

    available_roles = ['superuser', 'user', 'news_author', 'admin']

    def __init__(self, user, password):
        super().__init__(user, password)

    def create_user(self, username, password, role) -> None:
        try:
            res = self._exec(
                f"select create_user('{username}', '{password}', '{role}')"
            )
            print(res)
        except DBAPIError as e:
            self._handle_exception(str(e.orig))


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
    admin.create_user("Dimka", "1234", "superuser")

    user = UserMasterConnector('user_master', 'DummyP4S$W0RD')

