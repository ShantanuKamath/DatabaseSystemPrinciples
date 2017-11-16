from . import parser
from . import utils


def cte_scan(plan, start=False):

    sentence = utils.get_conjunction(start)

    if plan["Node Type"] == "CTE Scan":

        sentence += " the table is scanned using CTE scan "
        sentence += str(plan["CTE Name"]) + " which is stored in memory "

        if "Index Cond" in plan:
            sentence += " with condition(s) " + \
                plan["Index Cond"].replace('::text', '') + "."

        if "Filter" in plan:
            sentence += " the filtering condition applied is " + \
                plan["Filter"].replace('::text', '') + "."

    return sentence
