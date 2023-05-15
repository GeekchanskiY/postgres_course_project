''' Main app with some primary logic '''
# from JWT_logic import JWTHolder
from connector import CustomConnector, UserMasterConnector, CryptoMasterConnector
from sample_data import cryptos, users


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
        with open('/home/geek/repos/pg_course_project/create_tables.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_roles.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # with open('/home/geek/repos/pg_course_project/create_tablespaces.sql', 'r') as file:
        #     sql_commands = file.read()

        # self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/triggers.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/Security_functions.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/procedures.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_managers.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_default_users.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        #with open('/home/geek/repos/pg_course_project/create_users.sql', 'r') as file:
        #    sql_commands = file.read()

        #self.dev_connector._exec(sql_commands)


    # WorkFlow functions
    @measure_execution_time
    def get_stats(self):
        pass

    def create_crypto(self, user_token, **params):
        # self.crypto_manager.
        pass

    @measure_execution_time
    def fill_data(self):
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
    app.fill_data()

    drop_all = input("\n Drop database? \n (y/n) \n")
    if drop_all == "y":
        app.drop()


if __name__ == '__main__':
    main()
