''' Main app with some primary logic '''
# from JWT_logic import JWTHolder
from datetime import datetime, timedelta

from redis import UnixDomainSocketConnection
from connector import CustomConnector, UserMasterConnector, CryptoMasterConnector
from sample_data import create_random_cryptos, cryptos, users, get_sample_shots


import time


def measure_execution_time(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        elapsed_time = time.time() - start_time
        print(f"{func.__name__} execution time: {elapsed_time} seconds")
        return result
    return wrapper


class App:
    # Connector for startup and shutdown
    dev_connector: CustomConnector

    # User manager
    user_manager: UserMasterConnector

    # Crypto manager
    crypto_manager: CryptoMasterConnector

    def __init__(self, super_login, super_password) -> None:
        self.dev_connector = CustomConnector(super_login, super_password)
        self.startup()

        self.user_manager = UserMasterConnector('user_master', 'DummyP4S$W0RD')
        self.crypto_manager = CryptoMasterConnector('crypto_master', 'DummyP4S$W0RD')

    @measure_execution_time
    def startup(self):
        ''' Auto-executing on startup scripts '''
        # TODO: create better tablespace management

        # CREATE TABLESPACES

        try:
            with open('/home/geek/repos/pg_course_project/create_tablespaces.sql', 'r') as file:
                sql_commands = file.read()

            self.dev_connector._exec(sql_commands)
        except Exception as e:
            str(e)
            print("Tablespaces already exists, skipping")
            pass

        # CREATE EXTENSIONS

        with open('/home/geek/repos/pg_course_project/extensions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE TABLES

        with open('/home/geek/repos/pg_course_project/create_tables.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE FUNCTIONS

        with open('/home/geek/repos/pg_course_project/functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # SELECT FUNCTIONS

        with open('/home/geek/repos/pg_course_project/select_functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE ROLES


        with open('/home/geek/repos/pg_course_project/triggers.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE Security functions

        with open('/home/geek/repos/pg_course_project/Security_functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/procedures.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE MANAGER USERS

        with open('/home/geek/repos/pg_course_project/create_managers.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE DEFAULT USER (superuser)
        # (analog of django's on-init superuser)

        with open('/home/geek/repos/pg_course_project/create_default_users.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # CREATE INDEXES

        with open('/home/geek/repos/pg_course_project/indexes.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # with open('/home/geek/repos/pg_course_project/create_users.sql', 'r') as file:
        #     sql_commands = file.read()

        # self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_roles.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)


    # WorkFlow functions

    @measure_execution_time
    def get_stats(self):
        raise NotImplementedError('not ready...')

    @measure_execution_time
    def compare_index_vs_view(self):
        pass

    @measure_execution_time
    def extreme_fill(self):
        ''' fills tables with extremely large amount of data '''

        self.user_manager.login_user('admin', 'superP4$Sw0rD')
        uid = self.user_manager._get_my_id()
        counter = 1
        for crypto in create_random_cryptos(1000):
            print(f"Creating crypto {crypto} (#{counter}/1000)")
            counter += 1
            self.crypto_manager.create_crypro(
                uid,
                self.user_manager.jwt.get_jwt(),
                crypto['name'],
                crypto['symbol'],
                crypto['image'],
                crypto['price'],
                crypto['volume'],
                crypto['market_cap'],
                crypto['transactions']
            )

            # Generate stats for 2 month
            ex_data = get_sample_shots(crypto['price'], 100)
            curr_time = datetime.now()
            timestamp_interval = timedelta(days=1)

            # call get_jwt each time to make sure it has not outdated
            for i in range(len(ex_data[0])):
                curr_time = curr_time - timestamp_interval
                print('create shot')
                self.crypto_manager.create_crypto_shot(
                    uid,
                    self.user_manager.jwt.get_jwt(),
                    crypto['name'],
                    curr_time.strftime("%Y-%m-%d %H:%M:%S"),
                    ex_data[0][i],
                    ex_data[1][i],
                    ex_data[2][i],
                    ex_data[3][i],
                )

    @measure_execution_time
    def fill_data(self):
        ''' fills with small amount of example data '''
        self.user_manager.login_user('admin', 'superP4$Sw0rD')
        for user in users:
            if user['role'] == 'superuser':
                try:
                    self.user_manager.create_user(user['username'], user['password'],
                                                  user['role'])
                except Exception:
                    print(f'user {user["username"]} already exists!')
                login = self.user_manager.login_user(user['username'], user['password'])
                print(f'Login user {user["username"]} status is {login}')
            else:
                try:
                    self.user_manager.create_standard_user(user['username'], user['password'])
                except Exception:
                    print(f'user {user["username"]} already exists')

        self.user_manager.login_user('admin', 'superP4$Sw0rD')
        uid = self.user_manager._get_my_id()
        for crypto in cryptos:
            self.crypto_manager.create_crypro(
                uid,
                self.user_manager.jwt.get_jwt(),
                crypto['name'],
                crypto['symbol'],
                crypto['image'],
                crypto['price'],
                crypto['volume'],
                crypto['market_cap'],
                crypto['transactions']
            )

            ex_data = get_sample_shots(crypto['price'], 50)
            curr_time = datetime.now()
            timestamp_interval = timedelta(days=1)

            # call get_jwt each time to make sure it has not outdated
            for i in range(len(ex_data[0])):
                curr_time = curr_time - timestamp_interval
                self.crypto_manager.create_crypto_shot(
                    uid,
                    self.user_manager.jwt.get_jwt(),
                    crypto['name'],
                    curr_time.strftime("%Y-%m-%d %H:%M:%S"),
                    ex_data[0][i],
                    ex_data[1][i],
                    ex_data[2][i],
                    ex_data[3][i],
                )

    @measure_execution_time
    def example_functions(self): # TODO: decreace cyclomatic complexity
        ''' runs all available functions as test '''
        self.user_manager.login_user('admin', 'superP4$Sw0rD')
        uid = self.user_manager._get_my_id()
        while True:
            print('Choose action: \n 1 - select cryptos by page \n 2 - toggle like to crypto'
                  '\n 3 - select crypto comments \n 4 - get my likes \n 5 - comment'
                  '\n 6 - get crypto month stats \n 7 - delete crypto \n 8 - search crypto \n 0 - exit \n')
            i = int(input('-->'))
            if i == 1:
                try:
                    self.select_cryptos_by_pg()
                except Exception as e:
                    print(e)
            elif i == 2:
                try:
                    z = input('Input crypto_name \n -->')
                    print(self.user_manager.toggle_like(z))
                except Exception as e:
                    print(e)
            elif i == 3:
                try:
                    z = input('Input crypto_name \n -->')
                    print(self.crypto_manager.select_crypto_comments(
                        uid,
                        self.user_manager.jwt.get_jwt(),
                        z
                    ))
                except Exception as e:
                    print(e)
            elif i == 4:
                try:
                    print(self.user_manager.get_my_fav())
                except Exception as e:
                    print(e)
            elif i == 5:
                try:
                    c = input('input crypto_name \n -->')
                    title = input('input review title \n -->')
                    comment = input('input review text \n -->')
                    print(self.user_manager.comment(c, title, comment))
                except Exception as e:
                    print(e)
            elif i == 6:
                c = input('input crypto_name \n -->')
                res = (
                    self.select_crypto_month_stats(
                        uid,
                        self.user_manager.jwt.get_jwt(),
                        c
                    )
                )
                if res is not None:
                    for r in res:
                        print(r)
                else:
                    print("err")
            elif i == 7:
                try:
                    c = input('input crypto_name \n -->')
                    self.delete_crypto(
                        uid,
                        self.user_manager.jwt.get_jwt(),
                        c
                    )
                    print(f'Delteted crypto {c}')
                except Exception as e:
                    print(e)
            elif i == 8:
                try:
                    c = input('input search pattern \n -->')
                    res = self.search_crypto(
                        uid,
                        self.user_manager.jwt.get_jwt(),
                        c
                    )
                    if res is not None:
                        for r in res:
                            print(r)
                    else:
                        print('err')
                except Exception as e:
                    print(e)

            else:
                break

    @measure_execution_time
    def search_crypto(self, uid, jwt, query):
        res = self.crypto_manager.search_crypto(
            uid,
            jwt,
            query
        )
        return res

    @measure_execution_time
    def select_crypto_month_stats(self, uid, jwt, query):
        res = self.crypto_manager.select_crypto_month_stats(
            uid,
            jwt,
            query
        )
        return res

    @measure_execution_time
    def delete_crypto(self, uid, jwt, query):
        res = self.crypto_manager.delete_crypto(
            uid,
            jwt,
            query
        )
        return res

    @measure_execution_time
    def select_cryptos_by_pg(self):
        uid = self.user_manager._get_my_id()
        try:
            pages = int(input("How many pages to display? \n int \n --> "))
            for i in range(pages):
                res = self.crypto_manager.select_cryptos_by_page(
                    uid,
                    self.user_manager.jwt.get_jwt(),
                    i,
                    20
                )
                if res is not None:
                    print('\n \n name \t symbol \t price \t volume \t market_cap \t transactions \n')
                    for r in res:
                        r = str(r[0]).replace('(', '').replace(')', '').split(',')

                        print(r[0], r[1], r[3], r[4], r[5], r[6])
                    print('\n Image ignored, bytea too large for terminal :(')
        except ValueError:
            print("\n That's not an int... \n ")

    @measure_execution_time
    def drop(self):
        ''' Drops all the data inside database. Use carefully. '''
        with open('/home/geek/repos/pg_course_project/drop_tables.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/drop_roles.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/drop_functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        self.user_manager.redis.flush()


def main():
    app = App('postgres', 'postgres')
    fill = input("\n Fill database? \n (y/n) \n -->")
    if fill == "y":
        app.fill_data()

    extreme = input('\n phonk? \n (y/n) \n -->')
    if extreme == "y":
        app.extreme_fill()

    sample_funcs = input('\n sample functions? \n (y/n) \n -->')
    if sample_funcs == "y":
        app.example_functions()

    drop_all = input("\n Drop database? \n (y/n) \n -->")
    if drop_all == "y":
        app.drop()


if __name__ == '__main__':
    main()
