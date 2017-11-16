import json
from utils import get_conjuction, init_plan
import parser.parse_plan as pp

def aggregate(plan, start=False):

    parsed_plan = init_plan(plan, start)
	plurality = ["s", "are"] if len(plan.get("Group Key")) > 1 else ["", "is"]
    if plan["Strategy"] == "Sorted":
        parsed_plan += pp(plan["Plans"][0], start) + " " + get_conjuction()
        if "Group Key" in plan:
            parsed_plan += "the attribute{} used for grouping the result {}".format(plurality[0], plurality[1]) 
            for group_key in plan["Group Key"]:
                parsed_plan += group_key.replace("::text", "") + ", "
            parsed_plan = parsed_plan[:-2]
        if "Filter" in plan:
            parsed_plan += " and it is filtered using the condition " + plan["Filter"].replace("::text", "") + "."
        return parsed_plan

    if plan["Strategy"] == "Hashed":
        sentence = get_conjuction()
        group_keys = ','.join([k.replace("::text", "") for k in plan["Group Key"]])
        sentence += "all the rows are hashed based on the key{} {},".format(plurality[0], group_keys)
        sentence += "the selected rows are then returned."
        parsed_plan = parse_plan(plan["Plans"][0], start) + " " + sentence
        return parsed_plan

    if plan["Strategy"] == "Plain":
        parsed_plan = parse_plan(plan["Plans"][0], start) + " " + get_conjuction()
        return parsed_plan


if __name__ == "__main__":
    PLAN = '''
    {                                                        
       "Node Type": "Aggregate",                                      
       "Strategy": "Sorted",                                          
       "Partial Mode": "Simple",  
       "Parent Relationship": "InitPlan",                                    
       "Parallel Aware": false,                                       
       "Startup Cost": 513461.61,                                     
       "Total Cost": 519210.47,                                       
       "Plan Rows": 220200,                                           
       "Plan Width": 15,                                              
       "Group Key": ["a.author", "something else"],                                     
       "Filter": "(count(a.author) > 20)",
       "Plans": [                                         
            {                                                
            "Node Type": "Seq Scan",                       
            "Parent Relationship": "Outer",                
            "Parallel Aware": false,                       
            "Relation Name": "publication",                
            "Alias": "a",                                  
            "Startup Cost": 0.00,                          
            "Total Cost": 102857.50,                       
            "Plan Rows": 164431,                           
            "Plan Width": 23,                              
            "Filter": "(year = 2017)"                      
            }                                                
        ]
    }
    '''
    JSON_PLAN = json.loads(PLAN)
    print(aggregate(JSON_PLAN, start=True))

    test = '''
    {                                                   
       "Node Type": "Aggregate",                                 
       "Strategy": "Hashed",                                     
       "Partial Mode": "Simple",                                 
       "Parallel Aware": false,                                  
       "Startup Cost": 40297.34,                                 
       "Total Cost": 40494.72,                                   
       "Plan Rows": 19738,                                       
       "Plan Width": 23,                                       
       "Group Key": ["b.author"],                              
       "Plans": [                                                
        {                                                       
           "Node Type": "Unrecognize",                           
           "Parent Relationship": "Outer",                       
           "Parallel Aware": false,                              
           "Join Type": "Inner",                                 
           "Startup Cost": 16963.82,                             
           "Total Cost": 40198.65,                               
           "Plan Rows": 19738,                                   
           "Plan Width": 15
        }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(aggregate(test_plan))
