import json
import parser

def hash_join(plan, start=False):
   
    sentence = "{} {} ".format(parser.parse_plan(plan["Plans"][1], start), parser.parse_plan(plan["Plans"][0]))
    sentence += "The result produced by the previous operation is joined using Hash {} Join".format(plan["Join Type"])
    if 'Hash Cond' in plan:
		sentence += ' with condition {}.'.format(plan['Hash Cond'].replace("::text", ""))
	else 
		sentence += "."
    return sentence

if __name__ == "__main__":
    test = '''
    {                                                   
        "Node Type": "Hash Join",                        
        "Parent Relationship": "Outer",                   
        "Parallel Aware": false,                          
        "Join Type": "Semi",                              
        "Startup Cost": 16963.39,                         
        "Total Cost": 34094.11,                           
        "Plan Rows": 8582,                                
        "Plan Width": 22,                                 
        "Hash Cond": "(a.year = (min(publication.year)))",
        "Plans": [                                        
            {                                               
            "Node Type": "Seq Scan",                      
            "Parent Relationship": "Outer",               
            "Parallel Aware": false,                      
            "Relation Name": "publication",               
            "Alias": "a",                                 
            "Startup Cost": 0.00,                         
            "Total Cost": 15525.89,                       
            "Plan Rows": 574989,                          
            "Plan Width": 26                              
            },                                              
            {                                               
            "Node Type": "Hash",                          
            "Parent Relationship": "Inner",               
            "Parallel Aware": false,                      
            "Startup Cost": 16963.38,                     
            "Total Cost": 16963.38,                       
            "Plan Rows": 1,                               
            "Plan Width": 4
            }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(hash_join(test_plan, start=True))

    test_plan["Join Type"] = "Inner"
    print(hash_join(test_plan, start=True))
