import json
from parser import parser
from parser import utils


def general_parser(plan, start=False):
    text = utils.get_conjunction(start)
    text += "do " + plan["Node Type"] + ". "
    if "Plans" in plan:
        for successor in plan["Plans"]:
            text += parser.parse_plan(successor)
        return text


if __name__ == "__main__":
    test = '''
    {
        "Node Type": "Unrecognize",
        "Parent Relationship": "Outer",
        "Parallel Aware": false,
        "Relation Name": "publication",
        "Alias": "publication",
        "Startup Cost": 0.00,
        "Total Cost": 15525.89,
        "Plan Rows": 574989,
        "Plan Width": 0,
        "Plans" :[
            {
                "Node Type": "Seq Scan",
                "Parent Relationship": "Outer",
                "Parallel Aware": false,
                "Relation Name": "publication",
                "Alias": "publication",
                "Startup Cost": 0.00,
                "Total Cost": 15525.89,
                "Plan Rows": 574989,
                "Plan Width": 0
            }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(general_parser(test_plan, start=True))
