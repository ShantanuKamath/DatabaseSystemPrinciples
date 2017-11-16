"""
A class to for the query plan object.
"""
from os import system
from parser import parser
import json
import logging
import psycopg2


class QueryPlan:

    def __init__(self, host, dbname, user, password):

        # Configuring database connection
        logging.info("Starting database connection.")

        self.conn = psycopg2.connect(host=host, dbname=dbname, user=user, password=password)
        if self.conn:
            logging.info("Connected to database %s sucessfully!" % dbname)
        else:
            logging.info("Connection failed.")

        self.cursor = self.conn.cursor()

    def explain(self, query=None, loop=False):
        if query:
            self.execute(query)

        self.query = [""]
        while self.query[-1].strip().lower() != "quit":
            self.query.append("\n" + input("postgres=# ").strip())
            if self.query[-1][-1] == ";":
                self.query = "".join(self.query)
                self.execute()
                self.query = [""]
                if not loop:
                    break

    def execute(self, query=None):
        if query:
            self.query = query

        logging.info("Executing: " + self.query)
        self.cursor.execute("EXPLAIN (FORMAT JSON) " + self.query)
        plan = self.cursor.fetchall()
        print(plan)
        # convert plan to natural language
        converted_plan = parser.parse_plan(plan[0][0][0]["Plan"], True)
        logging.info("Plan: " + json.dumps(plan[0][0][0]["Plan"]))
        logging.info("Converted to: " + converted_plan)
        # Speak plan
        system("say %s" % converted_plan)
