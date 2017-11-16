from . import utils


def sequential_scan(plan, start=False):
    text = utils.get_conjunction(start)
    text += "a sequential scan is performed on the relation "
    if "Relation Name" in plan:
        text += plan['Relation Name']
    if "Alias" in plan:
        if plan['Relation Name'] != plan['Alias']:
            text += " under the alias name "
            text += plan['Alias']
    text += "."
    if "Filter" in plan:
        text += " This is bounded by the condition, "
        text += plan['Filter'].replace("::text", "")[1:-1]
        text += "."

    return text
