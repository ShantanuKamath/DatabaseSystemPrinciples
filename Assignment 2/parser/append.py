from . import parser
from . import utils


def append(plan, start=False):

    sentence = ""
    if "Plans" in plan:
        for child in plan["Plans"]:
            tmp = parser.parse_plan(child, start)
            if start:
                start = False
            sentence += tmp + " "
    if plan["Node Type"] == "Append":
        sentence += utils.get_conjunction(start) + \
            " the results of the scan are appended."

    return sentence
