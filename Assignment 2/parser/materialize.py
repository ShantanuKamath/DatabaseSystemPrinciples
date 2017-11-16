import json
import parser, utils 

def materialize(plan, start=False):
    text = ""
    if "Plans" in plan:
        for successor in plan["Plans"]:
            child_text = parser.parse_plan(successor, start)
            text += child_text 
            if start:
                start = False
    if plan["Node Type"] == "Materialize":
        text += utils.get_conjuction(start)
        text += " holding the results in memory enables efficient accessing. "
    return text
   
if __name__ == "__main__":
    test = '''
    {                                             
        "Node Type": "Materialize",                                        
        "Parent Relationship": "Inner",                                    
        "Parallel Aware": false,                                           
        "Startup Cost": 19215.45,                                          
        "Total Cost": 19223.67,                                            
        "Plan Rows": 274,                                                  
        "Plan Width": 15,                                                  
        "Plans": [                                                         
            {                                                                
                "Node Type": "Unrecognize",                                      
                "Strategy": "Sorted",                                          
                "Partial Mode": "Simple",                                      
                "Parent Relationship": "Outer",                                
                "Parallel Aware": false,                                       
                "Startup Cost": 19215.45,                                      
                "Total Cost": 19220.25,                                        
                "Plan Rows": 274,                                              
                "Plan Width": 23,                                              
                "Group Key": ["a_1.author"],                                   
                "Filter": "(count(a_1.author) >= 10)"                        
            }
        ]
    }
    '''
    test_plan = json.loads(test)
    print(materialize(test_plan, start=True))