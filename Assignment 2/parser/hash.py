import json
from . import parser
from . import utils


def hash(plan, start=False):
    if "Plans" in plan:
        sentence = parser.parse_plan(plan['Plans'][0], start)
        sentence += " The hash function creates an in-memory hash with the tuples from the source."
    else:
        sentence = utils.get_conjunction(start)
        sentence += " the hash function creates an in-memory hash with the tuples from the source"
    return sentence

