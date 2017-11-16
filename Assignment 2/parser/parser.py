from . import sequentialScan, limit, general_parser, materialize, mergeJoin, nestedLoopJoin, setOperation, duplicateElimination


def parse_plan(plan, start=False):

    PARSER_MAP = {
        "Seq Scan": sequentialScan.sequential_scan,
        "Limit": limit.limit,
        "Materialize": materialize.materialize,
        "Merge Join": mergeJoin.merge_join,
        "Nested Loop": nestedLoopJoin.nested_loop_join,
        "SetOp": setOperation.set_operation,
        "Unique": duplicateElimination.duplicate_elimination
    }

    node = plan["Node Type"]
    print(node)
    if node in PARSER_MAP:
        parser = PARSER_MAP[node]
    else:
        parser = general_parser.general_parser  # Add default parser
    print(parser)
    parsed_plan = parser(plan, start)
    return parsed_plan
