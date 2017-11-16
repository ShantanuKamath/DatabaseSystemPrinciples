"""
A class to for the query plan object.
"""

import psycopg2
import logging


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
        self.query = "SELECT * FROM Author"

        logging.info("Executing: " + self.query)
        self.cursor.execute("EXPLAIN (FORMAT JSON) " + self.query)
        plan = self.cursor.fetchall()
        print(plan)
