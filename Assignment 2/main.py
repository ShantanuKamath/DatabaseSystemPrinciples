"""
Main script to start application.
"""

from os import system

import logging
import json
from queryPlan import QueryPlan

def startLogger(filename):
    """
    Initialize logging object.
    """
    logging.basicConfig(filename=filename, level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        filemode='w')


def main():
    """
    Function to execute and generate query plan.
    """
    with open("config.json", "r") as file:
        config = json.load(file)

    startLogger(config["logging"]["path"])
    # Marking start of program.
    logging.info("Start logging.")

    db_config = config["db"]

    # Configuring database connection
    logging.info("Starting database connection.")

    query_plan = QueryPlan(db_config["host"], db_config["database"], db_config["username"],
                           db_config["password"])
    system("say Testing psycopg query execution ")
    # Marking end of program.
    logging.info("Finish logging.")


if __name__ == "__main__":
    main()
