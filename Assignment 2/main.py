"""
Main script to start application.
"""

from os import system
from queryPlan import QueryPlan
import logging
import json


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

    query_plan = QueryPlan(db_config["host"], db_config["database"], db_config["username"],
                           db_config["password"])

    query_plan.explain(loop=True)
    system("say Testing multiple query executions completed.")
    # Marking end of program.
    logging.info("Finish logging.")


if __name__ == "__main__":
    main()
