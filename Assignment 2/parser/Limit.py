# from .parser import parse_plan
from . import parser
from .utils import get_conjuction
# from . import utils

def limit(plan, start=False):
    text = parser.parse_plan(plan["Plans"][0], start)
    start = False
    text += get_conjuction(start)
    row_limit = plan["Plan Rows"]
    text += "The table scanning is done, but with a limitation of " + str(row_limit) + " items."
    return text
