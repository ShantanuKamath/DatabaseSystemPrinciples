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


if __name__ == "__main__":
    test = '''
    {
        "Node Type": "Group",
        "Parent Relationship": "Outer",
        "Parallel Aware": false,
        "Startup Cost": 0.42,
        "Total Cost": 60853.79,
        "Plan Rows": 574989,
        "Plan Width": 106,
        "Group Key": ["pub_key", "year"],
        "Plans": [
        {
            "Node Type": "Index Scan",
            "Parent Relationship": "Outer",
            "Parallel Aware": false,
            "Scan Direction": "Forward",
            "Index Name": "publication_pkey",
            "Relation Name": "publication",
            "Alias": "publication",
            "Startup Cost": 0.42,
            "Total Cost": 59416.31,
            "Plan Rows": 574989,
               "Plan Width": 106
        }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(group(test_plan, start=True))
