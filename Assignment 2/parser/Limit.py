import json
import utils 

def limit(plan, start=False):
    text = utils.get_conjuction(start)
    row_limit = plan["Plan Rows"]
    text = "The table scanning is done, but with a limitatation of " + str(row_limit) + " items."
    return text



