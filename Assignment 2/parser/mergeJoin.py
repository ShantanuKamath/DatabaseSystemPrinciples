from . import parser
from . import utils

def merge_join(plan, start=False):
    text = ""
    if 'Plans' in plan:
        for successor in plan['Plans']:
            text += parser.parse_plan(successor, start) + " "
            if start:
                start = False
    text += utils.get_conjuction(start)
    text += "merge join is employed to merge the preceeding result"
    if 'Merge Cond' in plan:
        text += " with the following condition: " + plan['Merge Cond'].replace("::text", "")
    if 'Join Type' == 'Semi':
        text += " however, the only row returned is that from the left table"
    else:
        text += "."

    return text