''' PGSQL connection logic here '''

from sqlalchemy import create_engine, text
# import psycopg2
# from sqlalchemy.schema import Sequence


class CustomConnector:
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
        self.check_role()
        # self.cur = self.conn.cursor()

    def check_role(self):
        rolname = self.exec(
            'SELECT rolname '
            'FROM pg_roles '
            'WHERE rolname = current_user;'
        )[0][0]
        if rolname != 'postgres':
            raise Exception('Invalid Priveleges')

    def exec(self, query_str: str) -> list:
        # self.cur.execute(query_str)
        # res = self.cur.fetchall()
        with self.engine.connect() as conn:
            result = conn.execute(text(query_str))
        return list(result.all())


if __name__ == '__main__':
    cc = CustomConnector('postgres', 'postgres')
    print(cc.exec('SELECT rolname '
                  'FROM pg_roles WHERE rolname = current_user;')[0][0])

