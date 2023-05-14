''' Main app with some primary logic '''
# from JWT_logic import JWTHolder
from connector import CustomConnector


class App:
    def __init__(self) -> None:
        pass

    def startup(self):
        pass

    def choose_action(self) -> bool:
        return True

    def exit(self):
        connector = CustomConnector('postgres', 'postgres')
        with open('/home/geek/repos/pg_course_project/drop_tables.sql', 'r') as file:
            sql_commands = file.read()

        connector._exec(sql_commands)

        with open('/home/geek/repos/pg_course_project/drop_roles.sql', 'r') as file:
            sql_commands = file.read()

        connector._exec(sql_commands)



if __name__ == '__main__':
    app = App()
    app.exit()
    exit()
