import json
import parser

def subquery_scan(plan, start=False):
    sentence = ''

    if 'Plans' in plan:
        for child in plan['Plans']:
            sentence += parser.parse_plan(child, start) + " "
            if start:
                start = False

    sentence += parser.get_conjuction(start)
    sentence += 'A subquery scan is performed on the result from the previous operation.'
    return sentence

if __name__ == "__main__":
    test = '''
    {                                                   
        "Node Type": "Subquery Scan",                                     
        "Parent Relationship": "Outer",                                   
        "Parallel Aware": false,                                          
        "Alias": "tmp_a",                                                 
        "Startup Cost": 48103.23,                                         
        "Total Cost": 48113.40,                                           
        "Plan Rows": 170,                                                 
        "Plan Width": 15,                                                 
        "Filter": "(NOT (hashed SubPlan 1))",
        "Plans":[
            {
                "Node Type": "Another Operation"
            }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(subquery_scan(test_plan, start=True))
