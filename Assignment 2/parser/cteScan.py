import json
import parser

def cte_scan(plan, start=False):
   
    sentence = parser.get_conjuction(start)
    
    if plan["Node Type"] == "CTE Scan":
        
        sentence += " the table is scanned using CTE scan "
        sentence += str(plan["CTE Name"]) + " which is stored in memory "
        
        if "Index Cond" in plan:
            sentence += " with condition(s) "+ plan["Index Cond"].replace('::text', '') + ".""

        if "Filter" in plan:
            sentence += " the filtering condition applied is "+ plan["Filter"].replace('::text', '') +"."

    return sentence

if __name__ == "__main__":
    test = '''
   {                                             
       "Node Type": "CTE Scan",                  
        "Parent Relationship": "Outer",           
        "Parallel Aware": false,                  
        "CTE Name": "x",                          
        "Alias": "x",                             
        "Startup Cost": 0.00,                     
        "Total Cost": 11651.98,                   
        "Plan Rows": 582599,                      
        "Plan Width": 218       
     }
    '''
    test_plan = json.loads(test)
    print(cte_scan(test_plan, start=True))
