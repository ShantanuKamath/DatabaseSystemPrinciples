import random


def get_conjunction(is_start=False):

    CONCAT_WORDS = [
        " Following this, ",
        " Next, ",
        " And then, ",
        " After that, ",
        " In addition to,"]

    if is_start:
        return "Initially, "

    return random.choice(CONCAT_WORDS)


def init_plan(plan, start=False):
    result = str(plan["Subplan Name"])
    if "Parent Relationship" in plan:
        if plan["Parent Relationship"] == "InitPlan":
            result = get_conjunction(start)
            result += "Since the calculation on " + plan["Node Type"] + " is done only once for " +\
                "the entire query, and it has to be done first, this node is evaluated first " +\
                "along with it's child."

    return result
