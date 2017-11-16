from testQueries import test_query_main
from queryPlan import QueryPlan
import logging
import json


def startLogger(filename):
    logging.basicConfig(filename=filename, level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        filemode='w')


def main():
    with open("config.json", "r") as file:
        config = json.load(file)

    startLogger(config["logging"]["path"])
    logging.info("Start logging.")

    db_config = config["db"]

    query_plan = QueryPlan(
        db_config["host"],
        db_config["database"],
        db_config["username"],
        db_config["password"])

    query_plan.explain(loop=True)

    # query_plan.exec_plan(test)

    # for query in test_query_main():
    #     query_plan.execute(query)

    # Marking end of program.
    logging.info("Finish logging.")


if __name__ == "__main__":
    main()
