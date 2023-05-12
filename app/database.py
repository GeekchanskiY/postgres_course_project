''' Database managing classes '''
from sqlalchemy import CursorResult, create_engine, text, exc


class DatabaseConnection:
    def __init__(self, user, password):
        # self.conn = psycopg2.connect(
        #     host='0.0.0.0',
        #     database='postgres',
        #     user=user,
        #     password=password
        # )
        self.engine = create_engine(f'postgresql+psycopg2://{user}:{password}@0.0.0.0/postgres')
        self.connection = self.engine.connect()
        # self.cur = self.conn.cursor()

    def exec(self, query_str: str) -> CursorResult | None:
        # self.cur.execute(query_str)
        # res = self.cur.fetchall()
        try:
            with self.engine.connect() as conn:
                return conn.execute(text(query_str))
        except exc.ProgrammingError:
            return None


if __name__ == '__main__':
    test = DatabaseConnection('user_master', 'DummyP4S$W0RD')
    res = test.exec('select * from users')
    print(res)
