"""
Main script to start application.
"""

from os import system
from queryPlan import QueryPlan
import logging
import json


def startLogger(filename):
    """
    Initialize logging object.
    """
    logging.basicConfig(filename=filename, level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        filemode='w')


def main():
    """
    Function to execute and generate query plan.
    """
    with open("config.json", "r") as file:
        config = json.load(file)

    startLogger(config["logging"]["path"])
    # Marking start of program.
    logging.info("Start logging.")

    db_config = config["db"]

    query_plan = QueryPlan(db_config["host"], db_config["database"], db_config["username"],
                           db_config["password"])

    # query_plan.explain(loop=True)
    test = json.loads(""" {                                             
       "Node Type": "Nested Loop",                                      
       "Parallel Aware": false,                                         
       "Join Type": "Inner",                                            
       "Startup Cost": 0.42,                                            
       "Total Cost": 27931.81,                                          
       "Plan Rows": 1,                                                  
       "Plan Width": 100,                                               
       "Plans": [                                                       
         {                                                              
           "Node Type": "Seq Scan",                                     
           "Parent Relationship": "Outer",                              
           "Parallel Aware": false,                                     
           "Relation Name": "pub_auth",                                 
           "Alias": "pub_auth",                                         
           "Startup Cost": 0.00,                                        
           "Total Cost": 27889.54,                                      
           "Plan Rows": 5,                                              
           "Plan Width": 23,                                            
           "Filter": "((author)::text = 'Hongli Xu'::text)"             
         },                                                             
         {                                                              
           "Node Type": "Index Scan",                                   
           "Parent Relationship": "Inner",                              
           "Parallel Aware": false,                                     
           "Scan Direction": "Forward",                                 
           "Index Name": "publication_pkey",                            
           "Relation Name": "publication",                              
           "Alias": "publication",                                      
           "Startup Cost": 0.42,                                        
           "Total Cost": 8.45,                                          
           "Plan Rows": 1,                                              
           "Plan Width": 100,                                           
           "Index Cond": "((pub_key)::text = (pub_auth.pub_key)::text)",
           "Filter": "(year = 2015)"                                    
         }                                                              
       ]                                                                
    }""")

    query_plan.exec_plan(test)
    # Marking end of program.
    logging.info("Finish logging.")


if __name__ == "__main__":
    main()
