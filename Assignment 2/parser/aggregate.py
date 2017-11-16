from . import parser
from . import utils


def aggregate(plan, start=False):

    parsed_plan = utils.init_plan(plan, start)
    plurality = ["s", "are"] if len(plan.get("Group Key")) > 1 else ["", "is"]
    if plan["Strategy"] == "Sorted":
        parsed_plan += parser.parse_plan(plan["Plans"]
                                         [0], start) + " " + utils.get_conjunction()
        if "Group Key" in plan:
            parsed_plan += "the attribute{} used for grouping the result {}".format(
                plurality[0], plurality[1])
            for group_key in plan["Group Key"]:
                parsed_plan += group_key.replace("::text", "") + ", "
            parsed_plan = parsed_plan[:-2]
        if "Filter" in plan:
            parsed_plan += " and it is filtered using the condition " + \
                plan["Filter"].replace("::text", "") + "."
        return parsed_plan

    if plan["Strategy"] == "Hashed":
        sentence = utils.get_conjunction()
        group_keys = ','.join([k.replace("::text", "")
                               for k in plan["Group Key"]])
        sentence += "all the rows are hashed based on the key{} {},".format(
            plurality[0], group_keys)
        sentence += "the selected rows are then returned."
        parsed_plan = parser.parse_plan(
            plan["Plans"][0], start) + " " + sentence
        return parsed_plan

    if plan["Strategy"] == "Plain":
        parsed_plan = parser.parse_plan(
            plan["Plans"][0],
            start) + " " + utils.get_conjunction()
        return parsed_plan
