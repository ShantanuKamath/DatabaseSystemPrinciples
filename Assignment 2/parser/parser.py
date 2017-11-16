from . import sequentialScan, limit, general_parser, materialize, mergeJoin, nestedLoopJoin, setOperation, duplicateElimination, append, aggregate, cteScan, functionScan, group, hash, hashJoin, indexScan, sort, subqueryScan, values


def parse_plan(plan, start=False):

    PARSER_MAP = {
        "Seq Scan": sequentialScan.sequential_scan,
        "Limit": limit.limit,
        "Materialize": materialize.materialize,
        "Merge Join": mergeJoin.merge_join,
        "Nested Loop": nestedLoopJoin.nested_loop_join,
        "SetOp": setOperation.set_operation,
        "Unique": duplicateElimination.duplicate_elimination,
        "Append": append.append,
        "Aggregate": aggregate.aggregate,
        "CTE Scan": cteScan.cte_scan,
        "Function Scan": functionScan.function_scan,
        "Group": group.group,
        "Hash": hash.hash,
        "Hash Join": hashJoin.hash_join,
        "Index Scan": indexScan.index_scan,
        "Index Only Scan": indexScan.index_scan,
        "Sort": sort.sort,
        "Subquery Scan": subqueryScan.subquery_scan,
        "Values Scan": values.values
    }

    node = plan["Node Type"]
    if node in PARSER_MAP:
        parser = PARSER_MAP[node]
    else:
        parser = general_parser.general_parser  # Add default parser
    parsed_plan = parser(plan, start)
    return parsed_plan
