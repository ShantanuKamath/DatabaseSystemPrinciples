import json
from utils import get_conjuction


def seq_scan_parser(plan, start=False):
    sentence = get_conjuction(start)
    sentence += "a sequential scan is performed on the relation "
    if "Relation Name" in plan:
        sentence += plan['Relation Name']
    if "Alias" in plan:
        if plan['Relation Name'] != plan['Alias']:
            sentence += " under the alias name "
            sentence += plan['Alias']
    sentence += "."
    if "Filter" in plan:
        sentence += " This is bounded by the condition, "
        sentence += plan['Filter'].replace("::text", "")[1:-1]
        sentence += "."

    return sentence
