"""
Main script to start application.
"""

from testQueries import test_query_main
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

    query_plan = QueryPlan(
        db_config["host"],
        db_config["database"],
        db_config["username"],
        db_config["password"])

    # query_plan.explain(loop=True)

#     test = json.loads(""" {
#         "Node Type": "Values Scan",
#         "Parallel Aware": false,
#         "Alias": "*VALUES*",
#         "Startup Cost": 0.00,
#         "Total Cost": 0.04,
#         "Plan Rows": 3,
#         "Plan Width": 36
#      }
# """)

#     query_plan.exec_plan(test)

    for query in test_query_main():
        query_plan.execute(query)

    # Marking end of program.
    logging.info("Finish logging.")


if __name__ == "__main__":
    main()
