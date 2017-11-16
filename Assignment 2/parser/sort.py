from . import parser
from . import utils


def sort(plan, start=False):

    sentence = ""
    if "Plans" in plan:
        for child in plan["Plans"]:
            tmp = parser.parse_plan(child, start)
            sentence += tmp + " "
            if start:
                start = False

    if plan["Node Type"] == "Sort":
        sentence += utils.get_conjunction(start)
        sentence += "the result is sorted on the attribute "
        if "DESC" in plan["Sort Key"]:
            sentence += str(plan["Sort Key"].replace('DESC',
                                                     '')) + " in desceding order."
        elif "INC" in plan["Sort Key"]:
            sentence += str(plan["Sort Key"].replace('INC',
                                                     '')) + " in increasing order."
        else:
            sentence += str(plan["Sort Key"]) + "."
    return sentence


if __name__ == "__main__":
    test = '''
   {
         "Node Type": "Sort",
           "Parent Relationship": "Outer",
           "Parallel Aware": false,
           "Startup Cost": 31061.74,
           "Total Cost": 32518.24,
           "Plan Rows": 582599,
           "Plan Width": 100,
           "Sort Key": ["title"],
           "Plans": [
             {
               "Node Type": "Seq Scan",
               "Parent Relationship": "Outer",
               "Parallel Aware": false,
               "Relation Name": "publication",
               "Alias": "publication",
               "Startup Cost": 0.00,
               "Total Cost": 15558.99,
               "Plan Rows": 582599,
               "Plan Width": 100
             }
           ]
     }
    '''
    test_plan = json.loads(test)
    print(sort(test_plan, start=True))
