import random


def get_conjuction(is_start=False):

    CONCAT_WORDS = ["Following this, ", "Next, ", "And then, ", "After that, ", "In addition to,"]

    if is_start:
        return "Initially, "

    return random.choice(CONCAT_WORDS)
