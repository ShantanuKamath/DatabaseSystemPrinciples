from . import parser
from . import utils


def hash_join(plan, start=False):

    sentence = "{} {} ".format(
        parser.parse_plan(
            plan["Plans"][1], start), parser.parse_plan(
            plan["Plans"][0]))
    sentence += "The result produced by the previous operation is joined using Hash {} Join".format(
        plan["Join Type"])
    if 'Hash Cond' in plan:
        sentence += ' with condition {}.'.format(
            plan['Hash Cond'].replace("::text", ""))
    else:
        sentence += "."
    return sentence
