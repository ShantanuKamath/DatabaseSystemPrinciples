# Assignment 2 - Database System Principles

The aim of the project is to vocalise the execution plan of a query in natural language. An python application is developed to allow the user to input the query through a command line interface, and returns the text as well as speech of the query execution plan in english natural language.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

The project is built using Python 3.6 and is not reverse compatible with Python 2.7.   

First, clone the repository.
```python
git clone https://github.com/ShantanuKamath/DatabaseSystemPrinciples.git
```

The requirements for this python application are provided in ```requirements.txt``` file.   

```python
pip3 install -r requirements.txt
```

Then, you need to provide the database configurations to allow interaction with the database. This needs to be provided in the ```config.json``` file.   

Example set up:
```python
{
    "db":{
        "host":"localhost", 
        "database":"db4031",
        "username":"shantanukamath",
        "password":""
    },
}
```

## Running the application

The application starts with the main file. ```main.py```

### Start the application

Run the following command in the folder of 
```python
python3 main.py
```

You will be shown a postgres like interface to allow you to enter a query.   
Note this is not an actual postgress interface and takes input only queries.

### Result of application

The command line would look like

```
postgres=# 
```

## Examples

Provide a query now and listen to explanation of the query plan.

Example:

```sql
SELECT * FROM Publication WHERE conf_name = 'acta';
```

Output (Audio):
```
Initially, a sequential scan is performed on the relation publication. This is bounded by the condition, conf_name = acta.
```

