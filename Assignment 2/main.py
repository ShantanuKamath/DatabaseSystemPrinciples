"""
Main Script to start application
"""

import logging
import json
from os import system


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
    logging.info("Start logging")

    system("say Testing logger and TTS")
    logging.info("Testing logger and TTS")

    logging.info("Finish logging")


if __name__ == "__main__":
    main()
