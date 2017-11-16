from . import parser
from . import utils


def values(plan, start=False):
    sentence = utils.get_conjunction(start)
    sentence += "A scan through the given values from the query is performed."
    return sentence


if __name__ == "__main__":
    test = '''
   {
        "Node Type": "Values Scan",
        "Parallel Aware": false,
        "Alias": "*VALUES*",
        "Startup Cost": 0.00,
        "Total Cost": 0.04,
        "Plan Rows": 3,
        "Plan Width": 36
     }
    '''
    test_plan = json.loads(test)
    print(values(test_plan, start=True))
