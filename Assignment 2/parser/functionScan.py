import json
import parser

def function_scan(plan, start=False):

    parsed_plan = parser.get_conjuction(start)
    parsed_plan += "the function {} is executed and the resulting set of tuples is returned.".format(plan["Function Name"])
    return parsed_plan

if __name__ == "__main__":
    test = '''
    {                                    
        "Node Type": "Function Scan",      
        "Parent Relationship": "Outer",    
        "Parallel Aware": false,           
        "Function Name": "generate_series",
        "Alias": "i",                      
        "Startup Cost": 0.00,              
        "Total Cost": 12.50,               
        "Plan Rows": 1000,                 
        "Plan Width": 8                    
    }                                                                         
    '''
    test_plan = json.loads(test)
    print(function_scan(test_plan, start=True))
