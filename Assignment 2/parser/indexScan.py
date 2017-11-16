import json
import parser

def index_scan(plan, start=False):

    sentence = parser.get_conjuction(start)
    if plan["Node Type"] == "Index Scan":
        sentence += "an index scan is performed using "+ plan["Index Name"]
        if "Index Cond" in plan:
            sentence += " with conditions {}".format(plan["Index Cond"].replace('::text', ''))
        sentence += ". Then, it opens the {} table and fetches all the tuples pointed to by the index".format(plan["Relation Name"])

        if "Filter" in plan:
            sentence += " The result is then filtered by {}.".format(plan["Filter"].replace('::text', ''))

    elif plan["Node Type"] == "Index Only Scan":
        sentence += "an index scan is performed using the index on {}".format(plan["Index Name"])
        if "Index Cond" in plan:
            sentence += " with the condition(s) {}.".format(plan["Index Cond"].replace('::text', ''))
        sentence += ". Then the matches found in index table scan are returned."
        if "Filter" in plan:
            sentence += " The result is then filtered by {}.".format(plan["Filter"].replace('::text', ''))
    return sentence


if __name__ == "__main__":
    test = '''
    {                                             
       "Node Type": "Index Scan",                          
       "Parallel Aware": false,                            
       "Scan Direction": "Forward",                        
       "Index Name": "publication_pkey",                   
       "Relation Name": "publication",                     
       "Alias": "publication",                             
       "Startup Cost": 0.42,                               
       "Total Cost": 8.44,                                 
       "Plan Rows": 1,                                     
       "Plan Width": 100,                                  
       "Index Cond": "((pub_key)::text = 'Saxena96'::text)"
    }
    '''
    test_plan = json.loads(test)
    print(index_scan(test_plan, start=True))

    test = '''
    {                                             
       "Node Type": "Index Only Scan",                           
       "Parallel Aware": false,                                  
       "Scan Direction": "Forward",                             
       "Index Name": "publication_pkey",                         
       "Relation Name": "publication",                           
       "Alias": "publication",                                   
       "Startup Cost": 0.42,                                     
       "Total Cost": 8.44,                                       
       "Plan Rows": 1,                                           
       "Plan Width": 21,                                         
       "Index Cond": "(pub_key = 'journals/acta/Saxena96'::text)"
    }
    '''
    test_plan = json.loads(test)
    print(index_scan(test_plan, start=True))
