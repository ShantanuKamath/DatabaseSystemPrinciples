from . import parser
from . import utils


def group(plan, start=False):
    parsed_plan = parser.parse_plan(plan["Plans"][0], start)
    parsed_plan += " " + utils.get_conjunction()
    group_keys = ",".join([k.replace("::text", "")
                           for k in plan["Group Key"][:-1]])
    plurality = "s" if len(plan["Plans"]) > 0 else ""
    parsed_plan += "the result from the previous operation is grouped together using the key{} ".format(
        plurality)
    parsed_plan += group_keys + "."
    return parsed_plan
