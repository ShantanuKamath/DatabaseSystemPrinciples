from . import parser
from . import utils


def materialize(plan, start=False):
    text = ""
    if "Plans" in plan:
        for successor in plan["Plans"]:
            child_text = parser.parse_plan(successor, start)
            text += child_text + " "
            if start:
                start = False
    if plan["Node Type"] == "Materialize":
        text += utils.get_conjunction(start)
        text += "holding the results in memory enables efficient accessing. "
    return text
