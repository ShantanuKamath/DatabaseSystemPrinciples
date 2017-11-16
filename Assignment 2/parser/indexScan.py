from . import parser
from . import utils


def index_scan(plan, start=False):

    sentence = utils.get_conjunction(start)
    if plan["Node Type"] == "Index Scan":
        sentence += "an index scan is performed using " + plan["Index Name"]
        if "Index Cond" in plan:
            sentence += " with conditions {}".format(
                plan["Index Cond"].replace('::text', ''))
        sentence += ". Then, it opens the {} table and fetches all the tuples pointed to by the index".format(
            plan["Relation Name"])

        if "Filter" in plan:
            sentence += " The result is then filtered by {}.".format(
                plan["Filter"].replace('::text', ''))

    elif plan["Node Type"] == "Index Only Scan":
        sentence += "an index scan is performed using the index on {}".format(
            plan["Index Name"])
        if "Index Cond" in plan:
            sentence += " with the condition(s) {}.".format(
                plan["Index Cond"].replace('::text', ''))
        sentence += ". Then the matches found in index table scan are returned."
        if "Filter" in plan:
            sentence += " The result is then filtered by {}.".format(
                plan["Filter"].replace('::text', ''))
    return sentence
