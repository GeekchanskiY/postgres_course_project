''' PGSQL connection logic here '''

from sqlalchemy import create_engine, text
# import psycopg2
# from sqlalchemy.schema import Sequence

#
#   Exceptions block
#


class InvalidPrivelegeExceprion(Exception):
    def __init__(self, message):
        self.message = message
        super().__init__(self.message)


#
# Connectors
#


class CustomConnector:
    ''' Admin Connector with all priveleges. Use only for tests! '''

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
        rolname = self.exec(
            'SELECT rolname '
            'FROM pg_roles '
            'WHERE rolname = current_user;'
        )[0][0]
        return str(rolname)

    def exec(self, query_str: str) -> list:
        # self.cur.execute(query_str)
        # res = self.cur.fetchall()
        with self.engine.connect() as conn:
            result = conn.execute(text(query_str))
        return list(result.all())


class UserMasterConnector(CustomConnector):
    ''' User master with users manage priveleges and methods '''

    rolename = 'user_manager'

    def __init__(self, user, password):
        super().__init__(user, password)


class NewsMasterConnector(CustomConnector):
    ''' News master to manage news '''


if __name__ == '__main__':
    cc = CustomConnector('postgres', 'postgres')

