import json
import parser
from utils import get_conjuction

def hash(plan, start=False):
    if "Plans" in plan:
        sentence = parser.parse_plan(plan['Plans'][0], start)
        sentence += " The hash function creates an in-memory hash with the tuples from the source."
    else:
        sentence = get_conjuction(start)
        sentence += " the hash function creates an in-memory hash with the tuples from the source"
    return sentence

if __name__ == "__main__":
    test = '''
    {                                                    
        "Node Type": "Hash",                               
        "Parent Relationship": "Inner",                    
        "Parallel Aware": false,                           
        "Startup Cost": 16963.36,                          
        "Total Cost": 16963.36,                            
        "Plan Rows": 35630,                                
        "Plan Width": 22,                                  
        "Plans": [                                         
        {                                                
            "Node Type": "Seq Scan",                       
            "Parent Relationship": "Outer",                
            "Parallel Aware": false,                       
            "Relation Name": "publication",                
            "Alias": "b",                                  
            "Startup Cost": 0.00,                          
            "Total Cost": 16963.36,                        
            "Plan Rows": 35630,                            
            "Plan Width": 22,                              
            "Filter": "(year = 2017)"                      
        }                                                
        ]                                                  
    }
    '''
    test_plan = json.loads(test)
    print(hash(test_plan, start=True))
