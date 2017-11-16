from . import parser
from . import utils
import json


def general_parser(plan, start=False):
    text = utils.get_conjunction(start)
    text += "do " + plan["Node Type"] + ". "
    if "Plans" in plan:
        for successor in plan["Plans"]:
            text += parser.parse_plan(successor)
    return text
