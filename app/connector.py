''' PGSQL connection logic here '''

from sqlalchemy import create_engine, text
import psycopg2


class CustomAdminConnector:
    def __init__(self, user, password):
        self.conn = psycopg2.connect(
            host='0.0.0.0',
            database='postgres',
            user='user_master',
            password='DummyP4S$W0RD'
        )
        self.engine = create_engine('postgresql+psycopg2://postgres:postgres@0.0.0.0/postgres')
        self.cur = self.conn.cursor()

    def exec(self, query_str: str) -> str:
        self.cur.execute(query_str)
        res = self.cur.fetchall()
        with self.engine.connect() as conn:
            result = conn.execute(text(query_str))
            for row in result:
                print(row)
        return str(res)


if __name__ == '__main__':
    cc = CustomAdminConnector()
    print(cc.exec('SELECT * FROM USERS'))

