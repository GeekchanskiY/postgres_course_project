''' Main app with some primary logic '''
# from JWT_logic import JWTHolder
from connector import CustomConnector

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
    def __init__(self, super_login, super_password) -> None:
        self.dev_connector = CustomConnector(super_login, super_password)
        self.startup()

    @measure_execution_time
    def startup(self):
        with open('/home/geek/repos/pg_course_project/create_roles.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        # with open('/home/geek/repos/pg_course_project/create_tablespaces.sql', 'r') as file:
        #     sql_commands = file.read()

        # self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_tables.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/create_managers.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

    @measure_execution_time
    def exit(self):
        with open('/home/geek/repos/pg_course_project/drop_tables.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/drop_roles.sql', 'r') as file:
            sql_commands = file.read()

        self.dev_connector._exec(sql_commands)


def main():
    app = App('postgres', 'postgres')
    app.exit()


if __name__ == '__main__':
    main()
