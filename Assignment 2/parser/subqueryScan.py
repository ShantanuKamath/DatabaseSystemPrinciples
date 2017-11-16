from . import parser
from . import utils


def subquery_scan(plan, start=False):
    sentence = ''

    if 'Plans' in plan:
        for child in plan['Plans']:
            sentence += parser.parse_plan(child, start) + " "
            if start:
                start = False

    sentence += utils.get_conjunction(start)
    sentence += 'A subquery scan is performed on the result from the previous operation.'
    return sentence
