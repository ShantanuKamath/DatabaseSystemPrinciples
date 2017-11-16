from . import parser
from . import utils


def duplicate_elimination(plan, start=False):
    text = parser.parse_plan(
        plan["Plans"][0],
        start) + " " + utils.get_conjuction()
    text += "each row is scanned from the sorted data, and duplicate elements (from the preceeding row) are eliminated."
    return text
