import json
import parser

def append(plan, start=False):
    
	sentence = ""
    if "Plans" in plan:
        for child in plan["Plans"]:
            tmp = parser.parse_plan(child, start)
            if start:
                start = False
            sentence += tmp + " "
    if plan["Node Type"] == "Append":
        sentence += parser.get_conjuction(start) + " the results of the scan are appended.""

    return sentence

if __name__ == "__main__":
    test = '''
    {                             
       "Node Type": "Append",              
       "Parallel Aware": false,            
       "Startup Cost": 0.00,               
       "Total Cost": 40150.02,             
       "Plan Rows": 1902002,               
       "Plan Width": 22,                   
       "Plans": [                          
         {                                 
           "Node Type": "Seq Scan",        
           "Parent Relationship": "Member",
           "Parallel Aware": false,        
           "Relation Name": "publication", 
           "Alias": "publication",         
           "Startup Cost": 0.00,           
           "Total Cost": 15558.99,         
           "Plan Rows": 582599,            
           "Plan Width": 21                
         },                                
         {                                 
           "Node Type": "Seq Scan",        
           "Parent Relationship": "Member",
           "Parallel Aware": false,        
           "Relation Name": "pub_auth",    
           "Alias": "pub_auth",            
           "Startup Cost": 0.00,           
           "Total Cost": 24591.03,         
           "Plan Rows": 1319403,           
           "Plan Width": 23                
         }                                 
       ]                                   
     }
    '''
    test_plan = json.loads(test)
    print(append(test_plan, start=True))
