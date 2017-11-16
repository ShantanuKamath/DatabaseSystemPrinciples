import json
from utils import get_conjuction

def limit(plan, start=False):
    text = get_conjuction(start)
    row_limit = plan["Plan Rows"]
    text = "The table scanning is done, but with a limitatation of " + str(row_limit) + " items."
    return text



