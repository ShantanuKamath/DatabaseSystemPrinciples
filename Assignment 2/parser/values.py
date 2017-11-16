from . import parser
from . import utils


def values(plan, start=False):
    sentence = utils.get_conjunction(start)
    sentence += "A scan through the given values from the query is performed."
    return sentence
