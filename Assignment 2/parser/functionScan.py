from . import utils
from . import parser


def function_scan(plan, start=False):

    parsed_plan = utils.get_conjunction(start)
    parsed_plan += "the function {} is executed and the resulting set of tuples is returned.".format(
        plan["Function Name"])
    return parsed_plan
