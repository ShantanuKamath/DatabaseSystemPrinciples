from . import parser
from . import utils


def sort(plan, start=False):

    sentence = ""
    if "Plans" in plan:
        for child in plan["Plans"]:
            tmp = parser.parse_plan(child, start)
            sentence += tmp + " "
            if start:
                start = False

    if plan["Node Type"] == "Sort":
        sentence += utils.get_conjunction(start)
        sentence += "the result is sorted on the attribute "
        if "DESC" in plan["Sort Key"]:
            sentence += str(plan["Sort Key"].replace('DESC',
                                                     '')) + " in desceding order."
        elif "INC" in plan["Sort Key"]:
            sentence += str(plan["Sort Key"].replace('INC',
                                                     '')) + " in increasing order."
        else:
            sentence += str(plan["Sort Key"]) + "."
    return sentence
